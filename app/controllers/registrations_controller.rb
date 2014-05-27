class RegistrationsController < Devise::RegistrationsController
	def create
		if User.where(:username => params[:user][:username]).first
			flash[:error] = "An account with this username already exists."
			session[:after_login_url] ||= params[:after_login_url]
			redirect_to "/users/sign_up"
		else
			super
		end
	end
end
