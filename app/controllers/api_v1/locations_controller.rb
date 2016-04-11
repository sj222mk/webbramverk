class LocationsController < ApplicationController
  before_filter :restrict_access
  respond_to :json
  
  def index
    if params[:search].present?
      @locations = Location.near(params[:search], 50, :order => :distance)
    else
      @locations = Location.all
    end
  end
  
  def show
    @location = Location.find(params[:id]) 
    if location.nil?
      respond_with message: "Resource not found", status: :not_found
    else
      respond_with location, status: :ok  # include:
    end
  end
  
  def new
    # @location = Location.new
  end
  
  def create
    @location = Location.new(location_params)
    if @location.save
      render json: location, status: :created
    else
      render json: location.errors, status: :bad_request
    end
  end
  
  def update
    @location = Location.find(params[:id])
    if location.update(location_params)
      render json: location, status: :created
    else
      respond_with location.errors, status: :bad_request
    end
  end
  
  def destroy
    @location = Location.find(params[:id])
    if location.nil?
      render json: { error: "No location was found" }, status: :not_found
    else
        location.destroy
        render json: { error: "Location is deleted" }, status: :ok
    end
  end
  
  def location_params
    params.permit(:address) #, :limit, :offset)
  end
  
  def restrict_access
    authenticate_or_request_with_http_token do [token, options]
      ApiKey.exists?(access_token: token)
    end
  end
end