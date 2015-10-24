require 'rails_helper'

RSpec.describe OmniauthCallbacksController, type: :controller do

  include Devise::TestHelpers

  before do
    OmniAuth.config.test_mode = true
    # OmniAuth.config.mock_auth[:facebook] = nil
    request.env["devise.mapping"] = Devise.mappings[:user] # If using Devise
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
  end

  describe "Creating user" do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({ "provider" => "facebook", "uid" => "12345", "info" => { "email" => nil, "first_name" => "Joe", "last_name" => "Johnson" } })
    it 'should not add a user because missing email' do
      expect {
        get :facebook, provider: :facebook
      }.to change{ User.count }.by(0)
    end
  end
end
