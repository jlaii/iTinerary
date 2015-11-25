require 'rails_helper'

RSpec.describe "user_trips/show", type: :view do
  before(:each) do
    @user_trip = assign(:user_trip, UserTrip.create!(
      :user_id => 1,
      :trip_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
