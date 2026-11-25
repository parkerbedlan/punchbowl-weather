class OpenWeatherAccount < ApplicationRecord
  class CallsPaused < StandardError; end

  # OpenWeather: "we would ask you to repeat your request in 10 minutes"
  # https://openweathermap.org/appid
  PAUSE_AFTER_RATE_LIMIT = 10.minutes
  PAUSE_AFTER_FAILURE = 1.minute

  def self.current
    find_or_create_by!(id: 1)
  end

  def call
    claim_first_call_after_pause if calls_paused_until
    result = yield OpenWeather::Client.new
    update!(calls_paused_until: nil) if calls_paused_until
    result
  rescue Faraday::Error => error
    pause_calls_after(error) if account_wide_failure?(error)
    raise
  end

  private

  def claim_first_call_after_pause
    claimed_row_count = self.class.where(id:, calls_paused_until: ..Time.current).update_all(
      calls_paused_until: PAUSE_AFTER_FAILURE.from_now,
      updated_at: Time.current
    )
    raise CallsPaused if claimed_row_count.zero?
  end

  def account_wide_failure?(error)
    status = error.response_status

    status.nil? || status >= 500 || status.in?([401, 429])
  end

  def pause_calls_after(error)
    pause = error.response_status == 429 ? PAUSE_AFTER_RATE_LIMIT : PAUSE_AFTER_FAILURE
    update!(calls_paused_until: pause.from_now)
    AuditEvent.create!(
      action: :pause_open_weather_calls,
      data: { error: error.class.name, http_status: error.response_status, paused_until: calls_paused_until }
    )
    logger.warn "OpenWeather calls are paused until #{calls_paused_until.iso8601} " \
                "after #{error.class} (HTTP #{error.response_status.inspect})"
  end
end
