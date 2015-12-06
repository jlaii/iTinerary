require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
	context "filling in date and destination" do
		it "should fail to fill in data- end_date before start_date" do
			get :save, :destination => "San Francisco", :startdate => "11/18/2015", :enddate => "11/16/2015"
			expect { raise "start_date later than end_date" }.to raise_error
		end
	end
end
