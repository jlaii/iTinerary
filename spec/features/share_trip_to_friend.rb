require "rails_helper"

RSpec.feature "Share Trip to Friend", :type => :feature do

  scenario "User creates a trip and itinerary, anonymous friend uses shareable link" do
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
    link = find("label", :id => "invitation_code")

    click_link "Logout"
    expect(page).to have_text("Signed out successfully.")


    #is there a way to get that generated link?
    # http://localhost:3000/trips/1/itinerary/?invitation_code=4d76e6fa-873c-4c8a-8dff-ccebfc98acea
    visit link

    expect(page).to have_text("Ooops! You do not have permission to view this page. ")

    fill_in "Email", :with => "friend@friend.com"
    fill_in "Password", :with => "12345678"
    fill_in "Password confirmation", :with => "12345678"
    click_button "Sign up"
    expect(page).to have_text("logged in as friend@friend.com")
    expect(page).to have_text("Your Itinerary for San Francisco")
  end

  scenario "Friend can navigate to dashboard and contribute to vote" do
    visit "/users/sign_in"
    fill_in "Email", :with => "friend@friend.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("Signed in successfully.")
    expect(page).to have_text("logged in as friend@friend.com")

    visit user_show_path
    expect(page).to have_text("Hi there,")

    visit show_attractions_path(:destination => "San Francisco")
    expect(page).to have_text("Attractions around San Francisco")

    choose "1 Louise M. Davies Symphony Hall"
    click_button "Let's go!", :match => :first

    visit user_show_path
    expect(page).to have_text("Hi there,")

    click_link "View votes"
    expect(page).to have_text("Louise M. Davies Symphony Hall Current vote: 1")
  end

  scenario "Original user sees trip's vote changed" do
    visit "/users/sign_in"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("Signed in successfully.")
    expect(page).to have_text("logged in as test@email.com")

    visit user_show_path
    expect(page).to have_text("Hi there,")

    click_link "View votes"
    expect(page).to have_text("Louise M. Davies Symphony Hall Current vote: 1")
  end

end