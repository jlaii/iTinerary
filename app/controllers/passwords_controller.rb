class PasswordsController < Devise::PasswordsController
  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    flash[:notice] = "Reset password instructions have been sent to your email. Once you successfully reset it, you can log in again."
    root_url
  end
end