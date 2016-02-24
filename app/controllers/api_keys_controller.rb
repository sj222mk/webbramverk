class ApiKeysController < ApplicationController
  before_action :admin_or_correct_user
 
  def index
      @user = current_user
      @api_keys = @user.api_keys.paginate(page: params[:page])
  end
  
  def show
  end
  
  def new
    @api_key = ApiKey.new if logged_in?
    @user = current_user
  end
  
  def create
    @api_key = ApiKey.create(api_key_params)
    @api_key.user = current_user
    if @api_key.save
      flash[:success] = "Api-key created!"
      redirect_to(user_api_keys_path(current_user))
    else
      flash[:error] = "Api-key NOT created!"
      redirect_to(new_user_api_key_path(current_user))
    end
  end

  def destroy
    if ApiKey.find(params[:id]).destroy
      flash[:success] = "Api-key deleted"
      redirect_to(user_api_keys_path(current_user))
    else
      flash[:error] = "Api-key NOT created!"
      redirect_to(user_api_keys_path(current_user))
    end
  end

  private

    def api_key_params
      params.require(:api_key).permit(:description)
    end
    
    def correct_user
      @user = User.find_by_id(params[:id])
      unless @user
        flash[:error] = "User not found" 
        redirect_to(root_url)
      end
      #redirect_to(root_url) unless current_user?(@user)
    end
    
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def admin_or_correct_user
      @user = current_user
      redirect_to(root_url) unless current_user.admin? || current_user?(@user)
    end
end