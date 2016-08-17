class Api::V1::ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  
  # To det away from the error "Can't verify CSRF token authenticity"
  skip_before_filter  :verify_authenticity_token

  # Must include access_token with every request
  before_filter :restrict_access

  before_filter :offset_and_limit_params, only: [:index]

  # User/developer must provide ApiKey for access
  def restrict_access
    unless ApiKey.exists?(access_token: params[:access_token])
      render json: { error: 'API-key invalid, access denied' }, status: :unauthorized
    end
  end

  # Check credentials from the header and try to authenticate, true if all goes fine else 400
  def check_authorization
    require 'base64'

    credentials = request.headers['Authorization']

    if credentials.nil?
      render json: { error: 'Missing credentials, access denied' }, status: :forbidden
    else
      credentials = Base64.decode64(credentials.split[1]).split(':')
      @current_creator = Creator.find_by(email: credentials[0].downcase)
      unless @current_creator && @current_creator.authenticate(credentials[1])
        render json: { error: 'Not authorized, wrong credentials'}, status: :forbidden
      end
      current_creator(@current_creator)
    end
  end

  def current_creator(creator)
    @current_creator = creator
  end
  
  # Default parameters 
  def offset_and_limit_params
    @offset = params[:offset].nil? ? 0  : params[:offset].to_i
    @limit  = params[:limit].nil?  ? 20 : params[:limit].to_i
  end

end
