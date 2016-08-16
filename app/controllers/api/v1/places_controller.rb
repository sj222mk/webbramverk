class Api::V1::PlacesController < Api::V1::ApiController
  before_action :check_authorization, only: [:create, :update, :destroy]

  def index
    places = []

    # Get places by creator and/or location
    places =
      if params[:location_id]
        Place.where(location_id: params[:location_id])
      elsif params[:creator_id]
        Place.where(creator_id: params[:creator_id])
      else
        Place.all
      end

    # Add offset, limit & order to current places if places are present from the search
    places = places.limit(@limit).offset(@offset).order("created_at DESC") if places.present?

    # Filter places nearest by, if params latitude and longitude are present
    if params[:latitude] && params[:longitude] && places.present?
      this_latitude = params[:latitude].to_f
      this_longitude = params[:longitude].to_f

      # Retrieve locations of specified coordinates
      nearby_locations = Location.near([this_latitude, this_longitude], 20, units: :km)
      if(nearby_locations.nil?)
      #if (nearby_locations = Location.where(latitude: this_latitude - 2..this_latitude + 2, longitude: this_longitude - 2..this_longitude + 2)).nil?
        render json: { error: "No places found within the area"}, status: :not_found and return
      else
        filteredPlaces = []
        places.each do |place|
          if nearby_locations.exists?(place.location)
            filteredPlaces.push(place)
          end
        end

        places = filteredPlaces
      end
    end

    # Check if places exists with all the filters.
    if places.present?
      # Serialize places to include offset(if not default), limit(if not default), amount
      render json: serialize_places(places), status: :ok
    else
      render json: { error: "No places found"}, status: :not_found
    end
  end

  #GET /api/v1/places/:id
  def show
    if place = Place.find_by_id(params[:id])
      render json: place, status: :ok
    else
      render json: { error: "The place was not found, the id does not exist" }, status: :not_found
    end
  end

  # POST /api/v1/places
  # Creates a place to current creator, only if authentication passed
  def create
    
    @place = Place.new(place_params.except(:location))
    @place.creator_id = @current_creator.id
    
    # Create a new location or use an existing location
    if !place_params[:location] || place_params[:location].nil?
     render json: { error: "The location was not provided"}, status: :bad_request
    else
      get_location
      @place.location = @location
      
       #Save the place
      if @place.save
        render json: serialize_place(@place), status: :created
      else
        render json: { error: "Something went wrong, the place could not be saved" }, status: :bad_request
      end
    end 
  end

  # PUT /api/v1/places/:id
  def update
    begin
      @place = Place.find(params[:id])
      
      # If user has submitted a new location, update location.
      if place_params[:location]
        get_location
        @place.location = @location
      end
      
      #Update
      if @place.update_attributes(place_params.except(:location))
        render json: serialize_place(@place), status: :ok
      else
        render json: { error: "Something went wrong, the place could not be updated" }, status: :bad_request
      end
    rescue
      render json: { error: "Something went wrong, the place do not exist. Did you provide the right id?" }, status: :bad_request
    end
  end

  # DELETE /api/v1/places/:id
  # Only able to delete the creators own places and not others.
  def destroy
    begin
      @place = Place.find_by_id(params[:id])
      @placename = @place.placename
      if Place.find_by_id(params[:id]).nil?
        render json: { error: "The place was not found. Did wou provide the correct id?" }, status: :not_found
      else
        
        @location = Location.find(@place.location_id) if Location.exists?(id: @place.location_id)
        @location_places = Place.where(location_id: @place.location_id)
        
        unless @location_places.nil? || @location.nil?
          # Destroy location only if the place was the "only" place associated with the resource.
            @location.destroy if @location_places.count <= 1
        end
          @place.destroy
          render json: { success: "#{@placename} är raderad"}, status: :accepted
      end
    rescue
      render json: { error: "Something went wrong, the place do not exist. Did you provide the right id?" }, status: :bad_request
    end
  end

  private
  def place_params
    params.require(:place).permit(:placetype, :placename, :grade, :description, location: [ :address])
  end

  # Custom serialize to work with normal json (with offset, limit and amount)
  def serialize_places(places)
    serialized_places = []

    places.each do |place|
      serialized_place = {
        id: place.id,
        placetype: place.placetype,
        placename: place.placename,
        grade: place.grade,
        description: place.description,
        #links: { self: api_v1_place_path(place.id) },
        creator: {
          id: place.creator.id,
          displayname: place.creator.displayname,
          email: place.creator.email,
          links: { self: api_v1_creator_path(place.creator.id), places: api_v1_creator_places_path(place.creator.id) }
        },
        location: {
          id: place.location.id,
          address: place.location.address,
          latitude: place.location.latitude,
          longitude: place.location.longitude,
          links: { self: api_v1_location_path(place.location.id), places: api_v1_location_places_path(place.location.id) }
        }
      }

      serialized_places.push(serialized_place)
    end

    # Return Object/JSON, conditions for including key and value
    obj = {}
    obj['offset'] = @offset unless @offset == 0 || @offset.nil?
    obj['limit'] = @limit unless @limit == 20 || @limit.nil?
    obj['amount'] = places.count 
    obj['places'] = serialized_places 
    
    return obj
  end

  def serialize_place(place)
      @places = []
      @places.push(place)
      serialize_places(@places)
  end
  
  def get_location
    # Try to find the location in db.
    if Location.exists?(place_params[:location].first)
      @location = Location.find_by(place_params[:location].first)
    else
      @location = Location.new(place_params[:location][0])
      unless @location.save
        render json: {error: "Something went wrong, the place could not be saved loc"}, status: :bad_request
      end
    end
  end
end