class AttractionsController < ApplicationController
  def show
    @show_attractions = City.find_by_name(params[:destination].titleize) ? true :
        Attraction.import_foursquare_attractions(params[:destination], 50)
    if not @show_attractions
      flash[:error] = "Could not find attractions in '#{params[:destination].titleize}'"
    end

  end
  def show_by_id
    @attraction = Attraction.find(params[:id])
    render "/attractions/attraction"
  end
end
