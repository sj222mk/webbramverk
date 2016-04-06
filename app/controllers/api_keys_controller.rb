class ApiKeysController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :create, :update, :destroy]
  before_action :admin_or_correct_user, only: [:create, :destroy]
  before_action :correct_user, only: [:create, :update]
  before_action :admin_user, only: :index
  
  def index
      @user = current_user
      @api_keys = @user.api_keys.paginate(page: params[:page])
  end
  
  def show
  end
  
  def new
    if logged_in?
      @api_key = ApiKey.new if logged_in?
      @user = current_user
    else
      redirect_to(root_url)
    end
  end
  
  def create
    @api_key = ApiKey.create(api_key_params)
    @api_key.user = current_user
    if @api_key.save
      flash[:success] = "Api-key created!"
      redirect_to (user_path(current_user))
    else
      flash[:error] = "Api-key NOT created!"
      redirect_to (user_path(current_user))
    end
  end

  def destroy
    if ApiKey.find(params[:id]).destroy
      flash[:success] = "Api-key deleted"
      redirect_to request.referrer
    else
      flash[:error] = "Api-key NOT deleted!"
      redirect_to request.referrer
    end
  end

  private

    def api_key_params
      params.require(:api_key).permit(:description)
    end
    
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def admin_or_correct_user
      @user = current_user
      redirect_to(root_url) unless current_user?(@user) || @user.admin?
    end
    
    def correct_user
      @user = current_user
      redirect_to(root_url) unless current_user?(@user)
    end
end