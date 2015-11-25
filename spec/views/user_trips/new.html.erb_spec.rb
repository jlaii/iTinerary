require 'rails_helper'

RSpec.describe "user_trips/new", type: :view do
  before(:each) do
    assign(:user_trip, UserTrip.new(
      :user_id => 1,
      :trip_id => 1
    ))
  end

  it "renders new user_trip form" do
    render

    assert_select "form[action=?][method=?]", user_trips_path, "post" do

      assert_select "input#user_trip_user_id[name=?]", "user_trip[user_id]"

      assert_select "input#user_trip_trip_id[name=?]", "user_trip[trip_id]"
    end
  end
end
