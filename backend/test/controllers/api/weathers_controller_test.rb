require 'test_helper'

class Api::WeathersControllerTest < ActionDispatch::IntegrationTest
  test 'get the weather returns json' do
    get api_location_weather_path(:boston), as: :json
    assert_response :success
  end

  test 'get the weather for a slug with no location returns not found' do
    get api_location_weather_path(:atlantis), as: :json
    assert_response :not_found
  end
end

