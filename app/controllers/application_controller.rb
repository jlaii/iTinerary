class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  def after_sign_in_path_for(resource)
		if session[:previous_url]
			session[:previous_url]
		elsif $params
  		trip_create_save_path($params) || root_path
		else
			root_path
  	end
	end
end
