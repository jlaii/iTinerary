require "rails_helper"



RSpec.feature "Add Trip to User", :type => :feature do

  scenario "User edit votes" do
    visit "/users/sign_up"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    fill_in "Password confirmation", :with => "12345678"
    click_button "Sign up"
    expect(page).to have_text("logged in as test@email.com")

    fill_in "destination", :with => "San Francisco"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around San Francisco")

    click_button "Let's go!", :match => :first
    expect(page).to have_text("Your Itinerary for San Francisco")

    visit user_show_path
    expect(page).to have_text("Hi there,")

    click_link "Revote"
    expect(page).to have_text("Attractions around San Francisco")

    choose "1 Louise M. Davies Symphony Hall"
    click_button "Let's go!", :match => :first

    visit user_show_path
    expect(page).to have_text("Hi there,")

    click_link "View votes"
    expect(page).to have_text("Louise M. Davies Symphony Hall Current vote: 1")

  end

end