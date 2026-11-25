require 'test_helper'

class Api::LocationsControllerTest < ActionDispatch::IntegrationTest
  test 'index returns every location with the fields the frontend reads' do
    get api_locations_path, as: :json

    assert_response :success
    assert_equal(
      [locations(:boston), locations(:new_york)].sort_by(&:id).map { |location|
        { 'id' => location.id, 'slug' => location.slug, 'name' => location.name }
      },
      response.parsed_body
    )
  end

  test 'show returns the location for a slug' do
    get api_location_path(:boston), as: :json

    assert_response :success
    assert_equal(
      { 'id' => locations(:boston).id, 'slug' => 'boston', 'name' => 'Boston, Massachusetts' },
      response.parsed_body
    )
  end

  test 'show for a slug with no location returns not found' do
    get api_location_path(:atlantis), as: :json

    assert_response :not_found
  end

  test 'create saves a place that OpenWeather knows' do
    places = [open_weather_place('Springfield', 'Missouri', 'US', lat: 37.2082, lon: -93.2923)]

    with_open_weather(places:) do
      assert_difference 'Location.count', 1 do
        post api_locations_path, params: { place: { city: 'Springfield', state: 'Missouri', country: 'US' } }, as: :json
      end
    end

    assert_response :created
    location = Location.find_by!(slug: 'springfield_missouri')
    assert_equal(
      { 'id' => location.id, 'slug' => 'springfield_missouri', 'name' => 'Springfield, Missouri' },
      response.parsed_body
    )
    assert_in_delta 37.2082, location.lat
  end

  test 'create returns the saved location for a place we already have' do
    with_open_weather do |client|
      assert_no_difference 'Location.count' do
        post api_locations_path, params: { place: { city: 'Boston', state: 'Massachusetts', country: 'US' } }, as: :json
      end

      assert_empty client.place_queries
    end

    assert_response :ok
    assert_equal 'boston', response.parsed_body['slug']
  end

  test 'create for a place OpenWeather does not know saves nothing' do
    with_open_weather(places: []) do
      assert_no_difference 'Location.count' do
        post api_locations_path, params: { place: { city: 'Atlantis', country: 'US' } }, as: :json
      end
    end

    assert_response :unprocessable_content
  end

  test 'create when the new slug is taken saves nothing' do
    Location.create!(name: 'Saint Louis, Missouri', slug: 'saint_louis_missouri')

    with_open_weather(places: [open_weather_place('Saint-Louis', 'Missouri', 'US')]) do
      post api_locations_path, params: { place: { city: 'Saint-Louis', state: 'Missouri', country: 'US' } }, as: :json
    end

    assert_response :unprocessable_content
  end

  test 'create when OpenWeather fails returns service unavailable' do
    with_open_weather(places: Faraday::TimeoutError.new) do
      assert_no_difference 'Location.count' do
        post api_locations_path, params: { place: { city: 'Springfield', state: 'Missouri', country: 'US' } }, as: :json
      end
    end

    assert_response :service_unavailable
  end

  test 'create with no place returns bad request' do
    post api_locations_path, params: {}, as: :json

    assert_response :bad_request
  end
end
