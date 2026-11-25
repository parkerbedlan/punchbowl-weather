require 'test_helper'

class Locations::WeatherRefreshConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  CONCURRENT_REQUEST_COUNT = 5

  teardown do
    Location.update_all(weather_data: nil, weather_fetched_at: nil, weather_refresh_after: nil)
  end

  test 'only one of the requests that see a refresh is due calls OpenWeather' do
    boston_id = locations(:boston).id
    Location.connection_pool.release_connection
    every_request_loaded_the_location = Concurrent::CyclicBarrier.new(CONCURRENT_REQUEST_COUNT)

    with_open_weather(open_weather_payload) do |client|
      requests = CONCURRENT_REQUEST_COUNT.times.map do
        Thread.new do
          Location.connection_pool.with_connection do
            location = Location.find(boston_id)
            every_request_loaded_the_location.wait(5)
            location.refresh_weather_if_due
          end
        end
      end
      requests.each(&:join)

      assert_equal 1, client.call_count
      assert_equal 45.3, Location.uncached { Location.find(boston_id) }.weather_data.dig('main', 'temp')
    end
  end
end
