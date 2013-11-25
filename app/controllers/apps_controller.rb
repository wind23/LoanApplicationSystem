# encoding: utf-8

class AppsController < ApplicationController

	def show
#		id = params[:id] # retrieve movie ID from URI route
		# will render app/views/movies/show.<extension> by default
	end

	def check_username
		if session[:current_user] == nil then
			flash[:notice] = "Login timed out!"
			redirect_to "/#{params[:ver]}/index" and return true
		end
		if params[:current_user] != session[:current_user][:username] then
			redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/apps" and return true
		end
		return false
	end

	def index
		if check_username then return end
		@current_user = User.find_by_user_name(session[:current_user][:username])
                
		#flash[:notice] = "#{@current_user.user_name}aaaaaaa"
		
		if @current_user.is_admin then  # admin default - show all the unchecked apps
			@get_apps = App.find(:all, :conditions => {:check_status => 0})
			@check_status_num = App.get_check_status_num
			render "admin_show"
			flash.keep
		else  # user default - show all my unchecked apps
			@apps_reim = App.find(:all, :conditions => {:app_type => 0, :applicant => @current_user.user_name})
			@apps_loan = App.find(:all, :conditions => {:app_type => 1, :applicant => @current_user.user_name})
			render "user_show"
		end
	end

	def new
		# default: render 'new' template
	end

	def new_app
		if check_username then return end
		if session[:current_user] == nil then
			flash[:notice] = "Login timed out!"
			redirect_to "/#{params[:ver]}/index" and return
		end
		@current_user = User.find_by_user_name(session[:current_user][:username])
		if params[:commit] != nil && params[:app][:details] != '' then
			sa = params[:app][:amount]
                        cn = 0
                        sa.each_byte do |t|
                           if t>=48 and t<=57
                           elsif t==46
                               cn = cn+1
                           else
                               cn = cn+2
                           end
                        end
                        if cn >= 2
                            flash[:notice] = "Invalid amount!"
                            redirect_to "/#{params[:ver]}/#{params[:current_user]}/new_#{params[:app_type]}_app" and return
                        end
                        params[:app][:amount] = sa.to_f.to_s
                        @app = App.create!(params[:app])
      @app.details = params[:app][:details]
			@app.app_date = Time.new
			@app.applicant = session[:current_user][:username]
			@app.app_type = App.get_pay_methods[params[:app_type]]
			@app.check_status = 0
			@app.save!
			flash[:notice] = "#{@app.details}Application successfully created."
			redirect_to "/#{params[:ver]}/#{params[:current_user]}/apps"
		else
			if params[:commit] != nil then
				flash[:notice] = "#{params[:app_type]}Details should not be empty!"
				#redirect_to "/#{params[:ver]}/#{params[:current_user]}/new_#{params[:app_type]}_app"
			end
		end
	end

        def delete
                times = params[:details]
                delist = {}
                App.all.each do |a|
                    if a.created_at.to_i.to_s == times
                        delist = a
                    end
                end
                #delist = App.find_by_created_at(times.to_i)
                if(delist == nil || delist == {} || ( delist[:applicant] != session[:current_user][:username] && session[:is_admin] == false) )
                    flash[:notice] = "No permission"
                    redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/apps" and return
                end
                App.destroy(delist)
                flash[:notice] = "#{times} has been removed."
                redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/apps"
        end


	def edit
	end

	def update
	end

	def destroy
	end
        
        #def user_management
        #    @current_user = User.find_by_user_name(session[:current_user][:username])
        #    @user = User.all
        #end

	def wait_for_verify
		if check_username then return end
		flash.keep
		@current_user = User.find_by_user_name(session[:current_user][:username])
		if @current_user.is_admin then
			@get_apps = App.find(:all, :conditions => {:check_status => [1, 2]})
			@check_status_num = App.get_check_status_num
			flash[:notice] = "aaaaaaaaaaa"
		else
			# current user is not admin
			# this situation shouldn't happen
			# just redirect top default apps page
			flash[:notice] = "No permission"
			redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/apps"
		end
	end
        
	def changes
		if check_username then return end
		@current_user = User.find_by_user_name(session[:current_user][:username])
		statusx = params[:s0].to_i
		statusy = params[:s1].to_i
		if @current_user.is_admin then
			if bad_change_status(statusx, statusy) then
				flash[:notice] = "Status#{statusx} cannot change to Status#{statusy}"
				redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/apps" and return
			end
			@app_now = App.find(params[:id])
			if @app_now == nil then
				flash[:notice] = "App with id{#{params[:id]} doesn't exist!"
				redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/#{App.get_admin_tags[(statusx+1)>>1][1]}" and return
			end
			if statusx == 1 && statusy == 3 then
			  #flash[:notice] = "#aaaaaaa"
				if params[:user] == nil || params[:user][:password] == "" then
					#flash[:notice] = "Account number should not be empty"
					redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/#{App.get_admin_tags[(statusx+1)>>1][1]}" and return
				end
			end
			@app_now.check_status = statusy
			@app_now.save!
			flash[:notice] = "操作成功"
			flash.keep
			redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/#{App.get_admin_tags[(statusx+1)>>1][1]}"
		else
			# current user is not admin
			# this situation shouldn't happen
			# just redirect to default apps page
		#	redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/apps"
		end
	end

	def bad_change_status(statusx, statusy)
		return (statusx == statusy) || (statusx == 0 && statusy > 2 ) || (statusx > 2 && statusy == 0)
	end
	
	def reviewed
		if check_username then return end 
		@current_user = User.find_by_user_name(session[:current_user][:username])
		if @current_user.is_admin then
			@get_apps = App.find(:all, :conditions => {:check_status => [3,4]})
			@check_status_num = App.get_check_status_num
			render "admin_reviewed"
		else
		end
		
	end
	
end
