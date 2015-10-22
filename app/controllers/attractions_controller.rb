class AttractionsController < ApplicationController
  def show
    @attraction = Attraction.find(params[:id])
    render template: "attractions/attraction"
  end
end
