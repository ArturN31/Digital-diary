require "application_system_test_case"

class UserProfilesTest < ApplicationSystemTestCase
  setup do
    @user_profile = user_profiles(:one)
  end

  test "visiting the index" do
    visit user_profiles_url
    assert_selector "h1", text: "User profiles"
  end

  test "should create user profile" do
    visit user_profiles_url
    click_on "New user profile"

    fill_in "User age", with: @user_profile.user_age
    fill_in "User gender", with: @user_profile.user_gender
    fill_in "User height", with: @user_profile.user_height
    fill_in "User", with: @user_profile.user_id
    fill_in "User pal value", with: @user_profile.user_pal_value
    fill_in "User weight", with: @user_profile.user_weight
    click_on "Create User profile"

    assert_text "User profile was successfully created"
    click_on "Back"
  end

  test "should update User profile" do
    visit user_profile_url(@user_profile)
    click_on "Edit this user profile", match: :first

    fill_in "User age", with: @user_profile.user_age
    fill_in "User gender", with: @user_profile.user_gender
    fill_in "User height", with: @user_profile.user_height
    fill_in "User", with: @user_profile.user_id
    fill_in "User pal value", with: @user_profile.user_pal_value
    fill_in "User weight", with: @user_profile.user_weight
    click_on "Update User profile"

    assert_text "User profile was successfully updated"
    click_on "Back"
  end

  test "should destroy User profile" do
    visit user_profile_url(@user_profile)
    click_on "Destroy this user profile", match: :first

    assert_text "User profile was successfully destroyed"
  end
end
