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
    visit "/"
    fill_in "destination", :with => "San Francisco"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around San Francisco")

    click_button "Let's go!", :match => :first

    expect(page).to have_text("You are going to: San Francisco")
    expect(page).to have_text("You haven't upvoted any attractions for this trip.")

  end

    
end