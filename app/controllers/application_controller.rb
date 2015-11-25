class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  def after_sign_in_path_for(resource)
  	if $params
  		trip_create_save_path($params) || root_path
  	else
			session[:previous_url] || root_path
  	end
	end
end
