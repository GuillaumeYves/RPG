require "test_helper"

class ForgeControllerTest < ActionDispatch::IntegrationTest
  test "should get upgrade" do
    get forge_upgrade_url
    assert_response :success
  end
end
