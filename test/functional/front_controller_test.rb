require 'test_helper'

class FrontControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get degrees" do
    get :degrees
    assert_response :success
  end

  test "should get proficiencies" do
    get :proficiencies
    assert_response :success
  end

  test "should get contacts" do
    get :contacts
    assert_response :success
  end

  test "should get courses" do
    get :courses
    assert_response :success
  end

  test "should get facilities" do
    get :facilities
    assert_response :success
  end

end
