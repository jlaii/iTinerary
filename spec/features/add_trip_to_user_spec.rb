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
  scenario "User logs in, creates a trip" do

    visit "/users/sign_in"
    fill_in "Email", :with => "test@email.com"
    fill_in "Password", :with => "12345678"
    click_button "Log in"
    expect(page).to have_text("Signed in successfully.")

    fill_in "destination", :with => "San Francisco"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around San Francisco")


    click_link "My Dashboard"

    user = User.find_by_email("test@email.com")
    for trip in user.trips
      expect(page).to have_link(trip_show_path(trip.id))
      click_link "#{trip_show_path(trip.id)}"
      expect(page).to have_text("You are going to: #{trip.city}")
      expect(page).to have_text("You haven't upvoted any attractions for this trip.")

      click_button "Generate Itinerary"
      expect(page).to have_text("Your Itinerary for San Francisco")
    end
  end

  scenario "User upvotes attraction and generates itinerary" do
    visit "/"
    fill_in "destination", :with => "San Francisco"
    fill_in "startdate", :with => "10/23/2015"
    fill_in "enddate", :with => "10/23/2015"
    click_button "Submit"
    expect(page).to have_text("Attractions around San Francisco")


    choose "1 1" #Louise M. Davies Symphony Hall
    #choose "1 2" #Asian Art Museum
    click_button "Let's go!", :match => :first

    expect(page).to have_text("You are going to: San Francisco")
    expect(page).to have_text("Attractions you've upvoted for this trip:")
    expect(page).to have_text("Louise M. Davies Symphony Hall")
    #expect(page).to have_text("Asian Art Museum")

    click_button "Generate Itinerary"
    expect(page).to have_text("Your Itinerary for San Francisco")
  end

    
end