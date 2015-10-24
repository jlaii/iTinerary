class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    user = User.from_omniauth(request.env["omniauth.auth"])
    # logger.debug user.errors.full_messages
    if user.persisted?
      # flash.notice = 'Logged in!'
      sign_in_and_redirect user
    else
      flash.notice = 'Logged in Failed' + user.errors.full_messages.join(".")
      redirect_to new_user_registration_url
    end
  end

  alias_method :facebook, :all


end
