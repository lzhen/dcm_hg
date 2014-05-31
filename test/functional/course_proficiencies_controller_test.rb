require 'test_helper'

class CourseProficienciesControllerTest < ActionController::TestCase
  setup do
    @course_proficiency = course_proficiencies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:course_proficiencies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create course_proficiency" do
    assert_difference('CourseProficiency.count') do
      post :create, :course_proficiency => @course_proficiency.attributes
    end

    assert_redirected_to course_proficiency_path(assigns(:course_proficiency))
  end

  test "should show course_proficiency" do
    get :show, :id => @course_proficiency.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @course_proficiency.to_param
    assert_response :success
  end

  test "should update course_proficiency" do
    put :update, :id => @course_proficiency.to_param, :course_proficiency => @course_proficiency.attributes
    assert_redirected_to course_proficiency_path(assigns(:course_proficiency))
  end

  test "should destroy course_proficiency" do
    assert_difference('CourseProficiency.count', -1) do
      delete :destroy, :id => @course_proficiency.to_param
    end

    assert_redirected_to course_proficiencies_path
  end
end
