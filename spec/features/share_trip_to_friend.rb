require "rails_helper"
require "Foursquare"

RSpec.feature "Share Trip to Friend", :type => :feature do

  before(:all) do
    @fake_api_response = File.read('spec/data/fake_api.json')
    @fake_hours_response = File.read('spec/data/sample_hours.json')
  end
  scenario "User creates a trip and itinerary, anonymous friend uses shareable link" do
    Foursquare.should_receive(:import_attractions).and_return(@fake_api_response)
    Foursquare.should_receive(:import_hours).at_most(50).times.and_return(@fake_hours_response)
    visit "/users/sign_up"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    fill_in "Password confirmation", :with => "12345678"
    click_button "Sign up"
    expect(page).to have_text("logged in as test@email.com")

    visit "/"
    fill_in "destination", :with => "San Francisco"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around San Francisco")

    click_button "Let's go!", :match => :first
    expect(page).to have_text("Your Itinerary for San Francisco")
    expect(page).to have_text("To invite your friends send them this link:")
    visit user_show_path
    expect(page).to have_text("Hi there")

    click_link "Revote"
    expect(page).to have_text("Attractions around San Francisco")

    # click_button "1 Louise M. Davies Symphony Hall"
    click_button "Let's go!", :match => :first
    expect(page).to have_text("Your Itinerary for San Francisco")

    visit user_show_path
    expect(page).to have_text("Hi there")

    click_link "View Votes"
    expect(page).to have_text("You haven't upvoted any attractions for this trip.")

    click_link "Logout"

    visit "/users/sign_in"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("Signed in successfully.")
    expect(page).to have_text("logged in as test@email.com")

    visit user_show_path
    expect(page).to have_text("Hi there")

    # click_link "View votes"
    # expect(page).to have_text("Louise M. Davies Symphony Hall Current vote: 1")
    click_link "Logout"
    expect(page).to have_text("Signed out successfully.")

    link = "http://127.0.0.1:#{Capybara.server_port}/trips/1/itinerary/?invitation_code=#{Trip.first.uuid}"
    visit link

    expect(page).to have_text("Ooops! You do not have permission to view this page. ")

    fill_in "Email", :with => "friend@friend.com"
    fill_in "Password", :with => "12345678"
    fill_in "Password confirmation", :with => "12345678"
    click_button "Sign up"
    expect(page).to have_text("logged in as friend@friend.com")
    expect(page).to have_text("Your Itinerary for San Francisco")

    visit user_show_path
    expect(page).to have_text("Hi there")
    click_link "Delete"
    expect(page).to have_text("You have no trips")

  end

end