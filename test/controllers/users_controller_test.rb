require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
    assert_select "title", "Sign up| Webbramverk"
  end
  
  test "should get show" do
    get :show
    assert_response :success
    assert_select "title", "@user.name | Webbramverk"
  end

end
