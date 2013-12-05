# encoding: utf-8

class AppsController < ApplicationController

	def show
#		id = params[:id] # retrieve movie ID from URI route
		# will render app/views/movies/show.<extension> by default
	end

	def check_username
		if session[:current_user] == nil then
			flash[:notice] = "Login timed out!"
			if params[:ver] != nil
				redirect_to "/#{params[:ver]}/index" 
			else
				redirect_to "/ch/index"
			end
			return true
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
			flash[:notice] = nil
			render "admin_show"
		else  # user default - show all my unchecked apps
      @apps_reim = @current_user.forms
      @apps_reim.each do |x|
      	x.apps.each do |y|
      		flash[:notice] = y
      		break
      	end
      	break
      end
			render "user_show"
		end
	end

	def new
		# default: render 'new' template
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
        
        def user_management
            @current_user = User.find_by_user_name(session[:current_user][:username])
            @user = User.all
            @check_status_num = App.get_check_status_num
        end

	def wait_for_verify
		if check_username then return end
		@current_user = User.find_by_user_name(session[:current_user][:username])
		if @current_user.is_admin then
			@get_apps = App.find(:all, :conditions => {:check_status => [1, 2]})
			@check_status_num = App.get_check_status_num
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
				if params[:account] == nil || params[:account][params[:id]] == "" then
					flash[:notice] = "#{params[:account]}    Account number should not be empty"
					redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/#{App.get_admin_tags[(statusx+1)>>1][1]}" and return
				else
					@app_now.account_num = params[:account][params[:id]]
				end
			end
			@app_now.check_status = statusy
			@app_now.save!
			flash[:notice] = "操作成功"
			redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/#{App.get_admin_tags[(statusx+1)>>1][1]}"
		else
			# current user is not admin
			# this situation shouldn't happen
			# just redirect to default apps page
			redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/apps"
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
