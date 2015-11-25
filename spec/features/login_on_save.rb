require "rails_helper"

RSpec.feature "Login on Save", :type => :feature do

  scenario "User not logged in while generating itinerary" do
    visit "/users/sign_up"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    fill_in "Password confirmation", :with => "12345678"
    click_button "Sign up"
    expect(page).to have_text("logged in as test@email.com")

    click_link "Logout"
    expect(page).to have_text("Signed out successfully.")

    fill_in "destination", :with => "San Francisco"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around San Francisco")

    click_button "Let's go!", :match => :first
    expect(page).to have_text("Log in")

    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("logged in as test@email.com")
    expect(page).to have_text("Your Itinerary for San Francisco")

    visit user_show_path
    expect(page).to have_text("Hi there,")

    visit show_attractions_path(:destination => "San Francisco")
    expect(page).to have_text("Attractions around San Francisco")

  end

end