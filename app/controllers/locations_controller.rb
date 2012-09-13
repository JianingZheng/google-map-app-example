class LocationsController < ApplicationController
  def new
    @location = Location.new
  end

  def create
    @location = Location.create(params[:location])
    redirect_to locations_path
  end

  def index
    @locations = Location.all
  end
end
