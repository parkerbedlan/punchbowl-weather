require 'test_helper'

class Api::WeathersControllerTest < ActionDispatch::IntegrationTest
  setup do
    freeze_time
    @boston = locations(:boston)
  end

  test 'the first request for a location calls OpenWeather and saves the weather' do
    with_open_weather(open_weather_payload) do |client|
      get api_location_weather_path(:boston), as: :json

      assert_response :success
      assert_equal 1, client.call_count
      assert_equal(
        {
          'temperature' => 45.3,
          'feels_like' => 38.05,
          'wind_speed' => 17.27,
          'humidity' => 36,
          'description' => 'few clouds',
          'icon_uri' => 'http://openweathermap.org/img/wn/02d@2x.png',
          'fetched_at' => Time.current.as_json
        },
        response.parsed_body
      )
      assert_equal 10.minutes.from_now, @boston.reload.weather_refresh_after
    end
  end

  test 'a request returns the saved weather and does not call OpenWeather before the refresh time' do
    save_weather(temperature: 30.0, fetched_at: 9.minutes.ago, refresh_after: 1.minute.from_now)

    with_open_weather(open_weather_payload) do |client|
      get api_location_weather_path(:boston), as: :json

      assert_response :success
      assert_equal 0, client.call_count
      assert_equal 30.0, response.parsed_body['temperature']
      assert_equal 9.minutes.ago.as_json, response.parsed_body['fetched_at']
    end
  end

  test 'a request at the refresh time calls OpenWeather and returns the new weather' do
    save_weather(temperature: 30.0, fetched_at: 10.minutes.ago, refresh_after: Time.current)

    with_open_weather(open_weather_payload) do |client|
      get api_location_weather_path(:boston), as: :json

      assert_response :success
      assert_equal 1, client.call_count
      assert_equal 45.3, response.parsed_body['temperature']
      assert_equal Time.current.as_json, response.parsed_body['fetched_at']
    end
  end

  test 'a request returns the saved weather when OpenWeather refuses the call' do
    save_weather(temperature: 30.0, fetched_at: 10.minutes.ago, refresh_after: Time.current)

    with_open_weather(open_weather_refusal(429)) do
      get api_location_weather_path(:boston), as: :json

      assert_response :success
      assert_equal 30.0, response.parsed_body['temperature']
      assert_equal 10.minutes.ago.as_json, response.parsed_body['fetched_at']
    end
  end

  test 'a failed call stops more calls for that location for one minute' do
    save_weather(temperature: 30.0, fetched_at: 10.minutes.ago, refresh_after: Time.current)

    with_open_weather(Faraday::TimeoutError.new) do |client|
      get api_location_weather_path(:boston), as: :json
      travel 59.seconds
      get api_location_weather_path(:boston), as: :json
      assert_equal 1, client.call_count

      travel 1.second
      get api_location_weather_path(:boston), as: :json
      assert_equal 2, client.call_count
    end
  end

  test 'a request gets service unavailable when OpenWeather fails and no weather is saved' do
    with_open_weather(Faraday::TimeoutError.new) do
      get api_location_weather_path(:boston), as: :json

      assert_response :service_unavailable
    end
  end

  test 'a request gets service unavailable when another request holds the claim and no weather is saved' do
    @boston.update!(weather_refresh_after: 1.minute.from_now)

    with_open_weather(open_weather_payload) do |client|
      get api_location_weather_path(:boston), as: :json

      assert_response :service_unavailable
      assert_equal 0, client.call_count
    end
  end

  test 'a failed call that concerns the whole account stops calls for every location' do
    with_open_weather(Faraday::TimeoutError.new) do |client|
      get api_location_weather_path(:boston), as: :json
      get api_location_weather_path(:new_york), as: :json

      assert_response :service_unavailable
      assert_equal 1, client.call_count
    end
  end

  test 'a request returns the saved weather and does not call OpenWeather during a pause' do
    save_weather(temperature: 30.0, fetched_at: 10.minutes.ago, refresh_after: Time.current)
    pause_open_weather_calls

    with_open_weather(open_weather_payload) do |client|
      get api_location_weather_path(:boston), as: :json

      assert_response :success
      assert_equal 0, client.call_count
      assert_equal 30.0, response.parsed_body['temperature']
    end
  end

  test 'get the weather for a slug with no location returns not found' do
    get api_location_weather_path(:atlantis), as: :json
    assert_response :not_found
  end

  private

  def save_weather(temperature:, fetched_at:, refresh_after:)
    payload = open_weather_payload.deep_merge('main' => { 'temp' => temperature })

    @boston.update!(
      weather_data: OpenWeather::Models::City::Weather.new(payload).as_json,
      weather_fetched_at: fetched_at,
      weather_refresh_after: refresh_after
    )
  end
end
