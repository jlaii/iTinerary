require 'rails_helper'

RSpec.describe "user_trips/edit", type: :view do
  before(:each) do
    @user_trip = assign(:user_trip, UserTrip.create!(
      :user_id => 1,
      :trip_id => 1
    ))
  end

  it "renders the edit user_trip form" do
    render

    assert_select "form[action=?][method=?]", user_trip_path(@user_trip), "post" do

      assert_select "input#user_trip_user_id[name=?]", "user_trip[user_id]"

      assert_select "input#user_trip_trip_id[name=?]", "user_trip[trip_id]"
    end
  end
end
