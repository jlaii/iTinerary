class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.email = auth.info.email
      # user.encrypted_password = auth.credentials.token
      user.password = Devise.friendly_token[0,20]
      logger.debug "--------------------Printing email--------------------"
      # logger.debug auth.info.name
      logger.debug user.first_name
      logger.debug user.encrypted_password
    end
  end

end
