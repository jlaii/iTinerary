class AttractionsController < ApplicationController
  def show
    @show_attractions = Attraction.find_by_city(params[:destination]) ? true :
        Attraction.import_foursquare_attractions(params[:destination])
  end
end
