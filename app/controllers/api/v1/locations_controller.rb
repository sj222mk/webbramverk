class Api::V1::LocationsController < ApplicationController
  
  # GET /api/v1/locations
  def index
    locations = Location.all

    if locations.nil?
      render json: { error: "No locations found"}, status: :not_found
    else
      render json: serialize_locations(locations)
    end
  end
  
  # GET /api/v1/locations/:id
  def show
    @location = Location.find(params[:id]) 
    if location.nil?
      respond_with message: "Resource not found", status: :not_found
    else
      respond_with location, status: :ok  
    end
  end
  
  # POST /api/v1/locations
  def create
    @location = Location.new(location_params)
    if @location.save
      render json: location, status: :created
    else
      render json: { error: "Something went wrong, the location could not be saved" }, status: :bad_request
    end
  end
  
  private
  def location_params
    params.require(:location).permit(:address)
  end
  
  # Custom serialize to work with normal json (with offset, limit and amount)
  def serialize_locations(locationlist)
    locations = []
    
    # Find out if result is an object or a collection of objects
    if locationlist.is_a?(Location)
      locations.push(locationlist)
    else
      locations = locationlist.limit(@limit).offset(@offset).order("updated_at DESC")
    end
    
    serialized_locations = []

    locations.each do |location|
      serialized_location = {
        location: {
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          links: {
            self: api_v1_location_path(location.id),
            places: api_v1_location_places_path(location.id)
          }
        }
      }

      serialized_locations.push(serialized_location)
    end

    json = {}
    json['offset'] = @offset unless @offset === 0
    json['limit'] = @limit unless @limit === 20
    json['amount'] = locations.count
    json['locations'] = serialized_locations

    return json
  end
end
