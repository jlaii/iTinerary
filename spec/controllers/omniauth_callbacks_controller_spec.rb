require 'rails_helper'

RSpec.describe OmniauthCallbacksController, type: :controller do

  include Devise::TestHelpers

  before do
    OmniAuth.config.test_mode = true
    # OmniAuth.config.mock_auth[:facebook] = nil
    request.env["devise.mapping"] = Devise.mappings[:user] # If using Devise
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
  end

  context "Testing Auth Hash" do
    subject { OmniAuth::AuthHash.new }
    it 'converts a supplied info key into an InfoHash object' do
      subject.info = {:first_name => 'Awesome'}
      expect(subject.info).to be_kind_of(OmniAuth::AuthHash::InfoHash)
      expect(subject.info.first_name).to eq('Awesome')
    end

    describe '#valid?' do
      subject { OmniAuth::AuthHash.new(:uid => '123', :provider => 'example', :info => {:name => 'Steven'}) }

      it 'is valid with the right parameters' do
        expect(subject).to be_valid
      end

      it 'requires a uid' do
        subject.uid = nil
        expect(subject).not_to be_valid
      end

      it 'requires a provider' do
        subject.provider = nil
        expect(subject).not_to be_valid
      end
    end

  end

  describe "Creating user" do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({ "provider" => "facebook", "uid" => "12345", "info" => { "email" => "test@gmail.com", "first_name" => "Joe", "last_name" => "Johnson" } })
    it 'should add a user' do
      expect {
        get :facebook, provider: :facebook
      }.to change{ User.count }.by(1)
    end
  end

end
