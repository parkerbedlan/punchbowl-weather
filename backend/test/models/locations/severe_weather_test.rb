require 'test_helper'

class Locations::SevereWeatherTest < ActiveSupport::TestCase
  setup { freeze_time }

  test "a tornado is a severe weather event" do
    save_weather(locations(:boston), condition_ids: [781])

    assert_equal ['tornado'], locations(:boston).severe_weather_events
  end

  test "few clouds and a light wind give no severe weather events" do
    save_weather(locations(:boston), condition_ids: [801], wind_speed: 17.27)

    assert_empty locations(:boston).severe_weather_events
  end

  test "a sustained wind of 40 miles per hour is a severe weather event" do
    save_weather(locations(:boston), condition_ids: [800], wind_speed: 40)

    assert_equal ['high wind'], locations(:boston).severe_weather_events
  end

  test "a wind just under 40 miles per hour is not a severe weather event" do
    save_weather(locations(:boston), condition_ids: [800], wind_speed: 39.9)

    assert_empty locations(:boston).severe_weather_events
  end

  test "each severe condition and a high wind are separate events" do
    save_weather(locations(:boston), condition_ids: [602, 511, 600], wind_speed: 45)

    assert_equal ['heavy snow', 'freezing rain', 'high wind'], locations(:boston).severe_weather_events
  end

  test "weather fetched more than 30 minutes ago gives no severe weather events" do
    save_weather(locations(:boston), condition_ids: [781], fetched_at: 31.minutes.ago)

    assert_empty locations(:boston).severe_weather_events
  end

  test "a location with no saved weather gives no severe weather events" do
    assert_empty locations(:boston).severe_weather_events
  end
end
