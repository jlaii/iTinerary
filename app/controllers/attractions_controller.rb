class AttractionsController < ApplicationController
  def show
    @show_attractions = City.find_by_name(params[:destination].titleize) ? true :
        Attraction.import_foursquare_attractions(params[:destination], 50)

    if not @show_attractions
      flash[:error] = "Could not find attractions in '#{params[:destination].titleize}'"
      redirect_to(root_url)
    end

  end

  def show_by_id
    begin
      @attraction = Attraction.find(params[:id])
      render "/attractions/attraction"
    rescue
      flash[:error] = "Attraction not found."
      redirect_to(root_url)
    end
  end
end
