require "rails_helper"



RSpec.feature "Add Trip to User", :type => :feature do

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
    visit "/users/sign_in"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("Signed in successfully.")

    visit "/"
    fill_in "destination", :with => "New York"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around New York")

    click_button "Let's go!", :match => :first
    expect(page).to have_text("Your Itinerary for New York")
  end

  scenario "User upvotes attractions" do
    skip "logged in user generates voted itinerary redirects back to root" do
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

      choose "1 Louise M. Davies Symphony Hall"
      click_button "Let's go!", :match => :first
      expect(page).to have_text("Your Itinerary for San Francisco")
    end
  end
end