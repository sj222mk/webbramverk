class Api::V1::PlacesController < Api::V1::ApiController
  before_action :check_authorization, only: [:create, :update, :destroy]

  def index
    # Get places by location, creator, grade or placename
    places = 
    if params[:address]
      getNearestPlaces(params[:address], @limit)
    elsif params[:creator_id]
      sortPlaces(Place.where(creator_id: params[:creator_id]))
    elsif params[:email]
      getPlacesByCreatorEmail()
    elsif params[:grade]
      sortPlaces(Place.where(grade: params[:grade]))
    elsif params[:placename]
      getPlacesByName()
    else
      Place.all
    end

    if places.first.is_a?(Place)
      render json: serialize_places(places), status: :ok
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
  def serialize_places(placelist)
    places = []
    
    # Find out if result is an object or a collection of objects
    if placelist.is_a?(Place)
      places.push(placelist)
    else
      places = placelist
    end
      
    serialized_places = []

    places.each do |place|
      serialized_place = {
        id: place.id,
        placetype: place.placetype,
        placename: place.placename,
        grade: place.grade,
        description: place.description,
        links: { self: api_v1_place_path(place.id) },
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
  
  def getNearestPlaces(address, limit)
    places = []
    
    if Location.exists?(:address => params[:address])
      distance = 1
      count = 0
      nearby_locations = []
      places = []
      
      # Retrieve nearby locations within distance
      # Looping until limit is set
      until count >= @limit || distance >= 200
        nearby_locations = Location.near(params[:address], distance, units: :km)
        
        unless nearby_locations.empty?
          nearby_locations.each do |location|
            nearby_places = Place.where(location_id: location.id)
            if nearby_places.exists?
              nearby_places.each do |place|
                unless places.include? place or places.count == 5
                    places.push(place)
                end
              end
            end
          end
        end
        count = count + 1
        distance = distance * 10
      end
      return places
    else
      render json: { error: 'The location does not exist, try again' }, status: :not_found
    end
  end
  
  def getPlacesByCreatorEmail()
    creator = Creator.find_by_email(params[:email])
    
    unless creator.nil?
      places = Place.where('creator_id =?', creator.id)
      return sortPlaces(places)
    end
      render json: { error: 'Nothing was found by that creator, try agian' }, status: :not_found
  end
  
  # Söker på namn, versaler/gemener spelar ingen roll
  def getPlacesByName()
    # Söker på namn, versaler/gemener spelar ingen roll
    places = Place.where('lower(placename) =?', params[:placename].downcase)
    if places.empty?
      # Om namnet inte hittas söker den på liknande namn
      places = Place.where('placename LIKE ?', "#{params[:placename]}%")
      
      if places.empty?
        render json: { error: 'Nothing was found with that name, try agian' }, status: :not_found
      end
    end
    return sortPlaces(places)
  end
  
  # Add offset, limit & order to current places if places are present from the search
  def sortPlaces(places)
    unless places.is_a?(Place)
      places = places.limit(@limit).offset(@offset).order("created_at DESC") if places.present?
    end
    return places
  end
end