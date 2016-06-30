class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  include SessionsHelper

#private

  # Confirms a logged-in user.
  def logged_in_user
    #return true
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
  
   #Check for api-key
  def restrict_access
    api_key = ApiKey.find_by_access_token(params[:access_token])
    
    #If key does not exist
    unless api_key
      render json: { message: "The API-key was not valid"}, status: :unauthorized
    end
  end
end
