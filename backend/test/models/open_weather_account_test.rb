require 'test_helper'

class OpenWeatherAccountTest < ActiveSupport::TestCase
  setup { freeze_time }

  test 'a call gets the OpenWeather client and returns the result of the block' do
    with_open_weather do |client|
      weather = OpenWeatherAccount.current.call { it.current_weather(lat: 1.5, lon: 2.5) }

      assert_equal 45.3, weather.main.temp
      assert_equal 1, client.call_count
      assert_nil OpenWeatherAccount.current.calls_paused_until
    end
  end

  test 'a rate limit refusal pauses every call for 10 minutes' do
    assert_equal 10.minutes.from_now, pause_after(open_weather_refusal(429))
  end

  test 'a refused key pauses every call for 1 minute' do
    assert_equal 1.minute.from_now, pause_after(open_weather_refusal(401))
  end

  test 'an OpenWeather server error pauses every call for 1 minute' do
    assert_equal 1.minute.from_now, pause_after(open_weather_refusal(500))
  end

  test 'a timeout pauses every call for 1 minute' do
    assert_equal 1.minute.from_now, pause_after(Faraday::TimeoutError.new)
  end

  test 'a refusal of one request does not pause the other calls' do
    assert_nil pause_after(open_weather_refusal(400))
  end

  test 'a pause writes an audit event with the cause' do
    pause_after(open_weather_refusal(429))

    audit_event = AuditEvent.sole
    assert_predicate audit_event, :pause_open_weather_calls?
    assert_equal(
      { 'error' => 'OpenWeather::Errors::Fault', 'http_status' => 429, 'paused_until' => 10.minutes.from_now.as_json },
      audit_event.data
    )
  end

  test 'a pause after no response writes an audit event with no HTTP status' do
    pause_after(Faraday::TimeoutError.new)

    assert_equal ['Faraday::TimeoutError', nil], AuditEvent.sole.data.values_at('error', 'http_status')
  end

  test 'a failed call that starts no pause writes no audit event' do
    pause_after(open_weather_refusal(400))

    assert_empty AuditEvent.all
  end

  test 'a call during a pause raises and does not reach OpenWeather' do
    pause_open_weather_calls(until_time: 1.second.from_now)

    with_open_weather do |client|
      assert_raises(OpenWeatherAccount::CallsPaused) { fetch_weather }
      assert_equal 0, client.call_count
    end
  end

  test 'the first call after a pause that succeeds ends the pause' do
    pause_open_weather_calls(until_time: Time.current)

    with_open_weather do |client|
      fetch_weather
      fetch_weather

      assert_equal 2, client.call_count
      assert_nil OpenWeatherAccount.current.calls_paused_until
    end
  end

  test 'the first call after a pause that fails starts a new pause' do
    pause_open_weather_calls(until_time: Time.current)

    assert_equal 10.minutes.from_now, pause_after(open_weather_refusal(429))
  end

  test 'only one call tests OpenWeather after a pause' do
    pause_open_weather_calls(until_time: Time.current)
    account_loaded_by_another_request = OpenWeatherAccount.current

    with_open_weather do |client|
      OpenWeatherAccount.current.call do
        assert_raises(OpenWeatherAccount::CallsPaused) { account_loaded_by_another_request.call { it.current_weather } }
        assert_equal 1.minute.from_now, OpenWeatherAccount.current.calls_paused_until
      end

      assert_equal 0, client.call_count
    end
  end

  private

  def fetch_weather
    OpenWeatherAccount.current.call { it.current_weather(lat: 1.5, lon: 2.5) }
  end

  def pause_after(error)
    with_open_weather(error) do
      assert_raises(error.class) { fetch_weather }
    end

    OpenWeatherAccount.current.calls_paused_until
  end
end
