require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    # assert_template 'application_controller/home'
    assert_select "a[href=?]", root_path, count: 3
    get signup_path
    # assert_select "title", full_title("Sign up")
  end
end