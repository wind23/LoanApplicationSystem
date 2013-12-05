# encoding: utf-8

class FormsController < ApplicationController
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
	
	def empty_form_entry(entry)
		t = params[:form_entry][entry.to_s]
		return t == nil || t[:details] == "" && t[:amount] == ""
	end
	
	def valid_form_entry(entry)
		t = params[:form_entry][entry.to_s]
		if t[:details] == nil || t[:details] == "" then
			return false
		end
		if t[:amount] == nil || !t[:amount].match(/^(\d{1,12})(\.\d{0,2})?$/) then
			return false
		end
		return true
	end
	
	def new_form
		if check_username then return end
		@TOT_APPS = Form.TOT_APPS
		@current_user = User.find_by_user_name(session[:current_user][:username])
		if params[:commit] != nil then
			valid_form = true
			empty_form = true
			flash[:notice] = "#{params[:form_entry]}"
			for i in 1..@TOT_APPS do
				if !empty_form_entry(i) then
					empty_form = false
					if !valid_form_entry(i) then
						valid_form = false
						flash[:notice] = params[:form_entry][i.to_s]
						break
					end
				end
			end	
			if !valid_form then
				flash[:notice] = "申请表填写错误，请重新填写#{params[:form_entry]}"
				return
			end
			if empty_form then
				flash[:notice] = "申请表不能为空，请重新填写"
				return
			end
			for i in 1..@TOT_APPS do
				if !empty_form_entry(i) then
					amount = params[:form_entry][i.to_s][:amount].to_f
=begin					
					x = amount[0].to_i
					if (amount[1] != nil) then
						x 
=end						
					flash[:notice] = amount
					break
				end
			end
		else
			
		end
	end
end
