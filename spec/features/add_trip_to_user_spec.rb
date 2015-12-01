require "rails_helper"
require "Foursquare"

RSpec.feature "Add Trip to User", :type => :feature do
  def stub_api_calls
      Foursquare.should_receive(:import_attractions).and_return(@fake_api_response)
      Foursquare.should_receive(:import_hours).at_most(50).times.and_return(@fake_hours_response)
  end
  before(:all) do
    @fake_api_response = File.read('spec/data/fake_api.json')
    @fake_hours_response = File.read('spec/data/sample_hours.json')
  end

  scenario "User signs up" do
    visit "/users/sign_up"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    fill_in "Password confirmation", :with => "12345678"
    click_button "Sign up"
    expect(page).to have_text("logged in as test@email.com")
  end

  scenario "User logs in" do
    visit "/users/sign_in"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("Signed in successfully.")
  end

  scenario "User upvotes no attractions" do
    stub_api_calls
    visit "/users/sign_in"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("Signed in successfully.")

    visit "/"
    fill_in "destination", :with => "San Francisco"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around San Francisco")

    click_button "Let's go!", :match => :first
    expect(page).to have_text("Your Itinerary for San Francisco")
  end

  # scenario "User upvotes attractions" do
  #   Foursquare.should_receive(:import_attractions).and_return(@fake_api_response)
  #   Foursquare.should_receive(:import_hours).at_most(50).times.and_return(@fake_hours_response)
  #   visit "/users/sign_in"
  #   fill_in "Email", :with => "test@email.com"
  #   fill_in "Password", :with => "12345678"
  #   click_button "Log in"
  #   expect(page).to have_text("Signed in successfully.")
  #
  #   visit "/"
  #   fill_in "destination", :with => "San Francisco"
  #   fill_in "startdate", :with => "10/23/2015"
  #   fill_in "enddate", :with => "10/23/2015"
  #   click_button "Submit"
  #   expect(page).to have_text("Attractions around San Francisco")
  #
  #   click_button "Let's go!", :match => :first
  #   expect(page).to have_text("Your Itinerary for San Francisco")
  # end
end