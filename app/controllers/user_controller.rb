class UserController < ApplicationController
	def login
		if params[:user] != nil then
			@current_user = User.find_by_user_name(params[:user][:username])
			if @current_user != nil && @current_user.user_pass == params[:user][:password] then
				session[:current_user] = params[:user]
				session[:is_admin] = @current_user.is_admin
				flash[:notice] = "#{session[:is_admin]}"
				redirect_to "/#{params[:ver]}/#{@current_user.user_name}/apps"
			else
				flash[:notice] = "Invalid username/password!"
				redirect_to "/#{params[:ver]}/index"
			end
		else
			flash[:notice] = "username/password should not be empty!"
			redirect_to "/#{params[:ver]}/index"
		end
	end
	
	def logout
		session[:current_user] = session[:is_admin] = nil
		flash[:notice] = "Logout succeeded!"
		redirect_to "/#{params[:ver]}/index"
	end
         
        def remove
                username = params[:user_name]
                delist = User.find_by_user_name(username)
                if(session[:is_admin] == true && delist != nil && delist[:user_name] != session[:current_user][:username])
                    User.destroy(delist)
                    flash[:notice] = "#{username} has been removed."
                else
                     flash[:notice] = "No permission"
                end
                redirect_to "/#{params[:ver]}/#{session[:current_user][:username]}/user_management"
        end
        def new_userc
                #redirect_to '/' and return
		if session[:current_user] == nil then
			flash[:notice] = "Login timed out!"
			redirect_to "/#{params[:ver]}/index" and return
		end
                if session[:is_admin] == false then
			flash[:notice] = "No permission"
			redirect_to "/#{params[:ver]}/#{params[:current_user]}/apps" and return 
                end
		@current_user = User.find_by_user_name(session[:current_user][:username])
                if params[:user][:is_admin] == 'Y' or params[:user][:is_admin] == 'y'
                        params[:user][:is_admin] = true
                else
                        params[:user][:is_admin] = false
                end

		if params[:commit] != nil && params[:user][:user_name] != ''
			@user = User.create!(params[:user])
			@user.save!
			flash[:notice] = "User successfully created."
			redirect_to "/#{params[:ver]}/#{params[:current_user]}/user_management"
		else
			if params[:commit] != nil then
				flash[:notice] = "#{params[:app_type]}Details should not be empty!"
				redirect_to "/#{params[:ver]}/#{params[:current_user]}/new_#{params[:app_type]}_app"
			end
		end
        end
end
