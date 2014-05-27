class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :require_user

	def after_sign_up_path_for(resource)
		path = params[:after_login_path] || "/games"
		if session[:after_login_path]
			path = session[:after_login_path]
			session[:after_login_path] = nil
		end
		return path
	end

	def after_sign_in_path_for(resource)
		path = params[:after_login_path] || "/games"
		if session[:after_login_path]
			path = session[:after_login_path]
			session[:after_login_path] = nil
		end
		return path
	end

	private

	def require_user
		unless current_user
			flash[:error] = "You need to sign in before continuing"
			session[:after_login_path] = request.path
			redirect_to "/users/sign_in"
		end
	end

end
