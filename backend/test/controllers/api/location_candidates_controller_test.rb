require 'test_helper'

class Api::LocationCandidatesControllerTest < ActionDispatch::IntegrationTest
  test 'index returns the places that match the query' do
    places = [
      open_weather_place('London', 'England', 'GB'),
      open_weather_place('London', 'Kentucky', 'US'),
      open_weather_place('Tokyo', nil, 'JP')
    ]

    with_open_weather(places:) do |client|
      get api_location_candidates_path(query: 'london'), as: :json

      assert_equal ['london'], client.place_queries
    end

    assert_response :success
    assert_equal(
      [
        { 'name' => 'London, England, GB', 'city' => 'London', 'state' => 'England', 'country' => 'GB' },
        { 'name' => 'London, Kentucky', 'city' => 'London', 'state' => 'Kentucky', 'country' => 'US' },
        { 'name' => 'Tokyo, JP', 'city' => 'Tokyo', 'state' => nil, 'country' => 'JP' }
      ],
      response.parsed_body
    )
  end

  test 'index with no query returns no places and makes no OpenWeather request' do
    with_open_weather do |client|
      get api_location_candidates_path, as: :json

      assert_empty client.place_queries
    end

    assert_response :success
    assert_empty response.parsed_body
  end

  test 'index when OpenWeather fails returns service unavailable' do
    with_open_weather(places: Faraday::TimeoutError.new) do
      get api_location_candidates_path(query: 'london'), as: :json
    end

    assert_response :service_unavailable
  end
end
