require "test_helper"

class TdeeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tdee_index_url
    assert_response :success
  end
end
