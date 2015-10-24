require "rails_helper"
RSpec.feature "Add Trip to User", :type => :feature do
  scenario "User logs in and creates a trip" do
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
    click_link "Go to your dashboard"

    user = User.find_by_email("test@email.com")
    for trip in user.trips
      expect(page).to have_link("/dashboard/trip/#{trip.id}")
      click_link "/dashboard/trip/#{trip.id}"
      expect(page).to have_text("You are going to: #{trip.city}")
      visit "/dashboard"
    end
  end
end