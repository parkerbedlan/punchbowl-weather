require 'test_helper'

class SevereWeatherAlertsJobTest < ActiveJob::TestCase
  TORNADO = 781
  HEAVY_SNOW = 602
  CLEAR_SKY = 800

  setup { freeze_time }

  test "a user gets one alert for severe weather at a favorite location" do
    save_weather(locations(:boston), condition_ids: [TORNADO])

    assert_output("Notified user_id #{users(:current).id}: Severe weather in Boston, Massachusetts: tornado.\n") do
      run_job
    end

    alert = SevereWeatherAlert.sole
    assert_equal [users(:current), locations(:boston), 'tornado'], [alert.user, alert.location, alert.event]
    assert_equal Time.current, alert.sent_at
  end

  test "calm weather sends no alert" do
    save_weather(locations(:boston), condition_ids: [CLEAR_SKY])

    assert_silent { run_job }
    assert_empty SevereWeatherAlert.all
  end

  test "a location with no favorite gets no alert and no OpenWeather call" do
    UserFavorite.delete_all

    assert_silent do
      client = run_job(open_weather_payload_with(condition_ids: [TORNADO]))
      assert_equal 0, client.call_count
    end
  end

  test "the job fetches weather that is due and alerts on it" do
    assert_output(/Severe weather in Boston, Massachusetts: tornado\./) do
      client = run_job(open_weather_payload_with(condition_ids: [TORNADO]))
      assert_equal 1, client.call_count
    end
  end

  test "the job does not call OpenWeather for weather that is still fresh" do
    save_weather(locations(:boston), condition_ids: [CLEAR_SKY])

    assert_equal 0, run_job.call_count
  end

  test "a failed fetch does not alert again on old weather" do
    save_weather(locations(:boston), condition_ids: [TORNADO], fetched_at: 31.minutes.ago)

    assert_silent { run_job(Faraday::TimeoutError.new) }
  end

  test "the same event does not send again within 6 hours" do
    save_weather(locations(:boston), condition_ids: [TORNADO])
    assert_output(/tornado/) { run_job }

    travel 6.hours - 1.second
    save_weather(locations(:boston), condition_ids: [TORNADO])

    assert_silent { run_job }
  end

  test "the same event sends again after 6 hours" do
    save_weather(locations(:boston), condition_ids: [TORNADO])
    assert_output(/tornado/) { run_job }

    travel 6.hours + 1.second
    save_weather(locations(:boston), condition_ids: [TORNADO])

    assert_output(/tornado/) { run_job }
    assert_equal 2, SevereWeatherAlert.count
  end

  test "a different event sends within 6 hours" do
    save_weather(locations(:boston), condition_ids: [HEAVY_SNOW])
    assert_output(/heavy snow/) { run_job }

    travel 10.minutes
    save_weather(locations(:boston), condition_ids: [TORNADO])

    assert_output("Notified user_id #{users(:current).id}: Severe weather in Boston, Massachusetts: tornado.\n") do
      run_job
    end
  end

  test "the same event at another favorite location sends its own alert" do
    users(:current).user_favorites.create!(location: locations(:new_york))
    save_weather(locations(:boston), condition_ids: [TORNADO])
    assert_output(/Boston/) { run_job }

    save_weather(locations(:new_york), condition_ids: [TORNADO])

    assert_output("Notified user_id #{users(:current).id}: Severe weather in New York, New York: tornado.\n") do
      run_job
    end
  end

  test "a user who favorites the location during the storm gets the alert on the next run" do
    save_weather(locations(:boston), condition_ids: [TORNADO])
    assert_output(/tornado/) { run_job }

    late_user = User.create!
    late_user.user_favorites.create!(location: locations(:boston))

    assert_output("Notified user_id #{late_user.id}: Severe weather in Boston, Massachusetts: tornado.\n") do
      run_job
    end
  end

  test "an alert that was saved but not sent goes out on the next run, once" do
    save_weather(locations(:boston), condition_ids: [TORNADO])
    unsent_alert = SevereWeatherAlert.create!(user: users(:current), location: locations(:boston), event: 'tornado')

    assert_output("Notified user_id #{users(:current).id}: Severe weather in Boston, Massachusetts: tornado.\n") do
      run_job
    end

    assert_equal Time.current, unsent_alert.reload.sent_at
    assert_equal 1, SevereWeatherAlert.count
  end

  private

  def run_job(payload_or_error = open_weather_payload)
    with_open_weather(payload_or_error) do |client|
      SevereWeatherAlertsJob.perform_now
      client
    end
  end
end
