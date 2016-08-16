class Api::V1::CreatorsController < Api::V1::ApiController
  before_action :check_authorization, only: [:update, :destroy]
  
  # GET /api/v1/creators
  def index
    if params[:email]
      @creator = Creator.find_by_email(params[:email])

      if @creator.nil?
        render json: { error: "No creator with that email found"}, status: :not_found
      else
        render json: serialize_creator(@creator), status: :ok
      end
    else
      @creators = Creator.all

      if @creators.nil?
        render json: { error: "No creators found"}, status: :not_found
      else
        @creators = @creators.limit(@limit).offset(@offset).order("created_at DESC")
        render json: serialize_creators(@creators), status: :ok
      end
    end
  end

  #GET /api/v1/creators/:id
  def show
    @creator = Creator.find_by_id(params[:id])

    if @creator.nil?
      render json: { error: "No creator with that id exists" }, status: :not_found
    else
      render json: serialize_creator(@creator), status: :ok
    end
  end

  def new
    #@creator = Creator.new
  end
  
  #POST /api/v1/creators/
  def create
    #Check if email i s allready registered
    creator = Creator.find_by_email(creator_params[:email])
    if creator.nil? 
      @creator = Creator.new(creator_params)
      if @creator.save
        render json: serialize_creator(@creator), status: :created
      else
        render json: { error: "Something went wrong, the creator could not be saved" }, status: :bad_request
      end
    else
      render json: { error: "The creator could not be saved, the email address is allready registered" }, status: :bad_request
    end
  end
  
  #PUT /api/v1/creators/:id
  def update
    begin
      @creator = Creator.find(params[:id])
      if @creator.update_attributes(creator_params)
        render json: serialize_creator(@creator), status: :created
      else
        render json: { error: "Something went wrong, the creator could not be updated" }, status: :bad_request
      end
    rescue
      render json: { error: "Something went wrong, the creator do not exist. Did you provide the right id?" }, status: :bad_request
    end
  end
  
  #DELETE /api/v1/creators/:id
  def destroy
    begin
      @name = Creator.find(params[:id]).displayname
      Creator.find(params[:id]).destroy
      render json: { success: "#{@name} är raderad"}, status: :accepted
    rescue
      render json: { error: "Something went wrong, the creator do not exist. Did you provide the right id?" }, status: :bad_request
    end
  end
  
  private
  def creator_params
    params.require(:creator).permit(:displayname, :email, :password) 
  end
  
  #def access_params
   # params.require(:access_token)[0]
  #end
  
  # Custom serialize to work with normal json (with offset, limit and amount)
  def serialize_creators(creators)
    serialized_creators = []

    creators.each do |creator|
      serialized_creator = {
        creator: {
          id: creator.id,
          displayname: creator.displayname,
          email: creator.email,
          links: {
            self: api_v1_creator_path(creator.id),
            places: api_v1_creator_places_path(creator.id)
          }
        }
      }

      serialized_creators.push(serialized_creator)
    end

    json = {}
    json['offset'] = @offset unless @offset === 0
    json['limit'] = @limit unless @limit === 20
    json['amount'] = creators.count
    json['creators'] = serialized_creators

    return json
  end
  
  def serialize_creator(creator)
    @creators = []
    @creators.push(creator)
    serialize_creators(@creators)
  end
  
end
