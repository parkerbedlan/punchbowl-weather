module Locations
  module WeatherRefresh
    extend ActiveSupport::Concern

    # OpenWeather: "we recommend making API calls no more than once in 10 minutes for each location"
    # https://openweathermap.org/appid#apicare
    WEATHER_FRESH_FOR = 10.minutes
    WEATHER_RETRY_AFTER = 1.minute

    included do
      scope :weather_refresh_due, -> {
        where(weather_refresh_after: nil).or(where(weather_refresh_after: ..Time.current))
      }
    end

    def weather_refresh_due?
      weather_refresh_after.nil? || weather_refresh_after <= Time.current
    end

    def refresh_weather_if_due
      return unless weather_refresh_due?

      claimed_row_count = self.class.weather_refresh_due.where(id:).update_all(
        weather_refresh_after: WEATHER_RETRY_AFTER.from_now,
        updated_at: Time.current
      )
      fetch_weather if claimed_row_count == 1
    end

    private

    def fetch_weather
      weather = OpenWeatherAccount.current.call { it.current_weather(lat:, lon:) }
      fetched_at = Time.current

      update!(
        weather_data: weather.as_json,
        weather_fetched_at: fetched_at,
        weather_refresh_after: fetched_at + WEATHER_FRESH_FOR
      )
    rescue OpenWeatherAccount::CallsPaused
      logger.info "Skipped the OpenWeather request for #{slug} while calls are paused"
    rescue Faraday::Error => error
      logger.warn "The OpenWeather request for #{slug} failed with #{error.class} (HTTP #{error.response_status.inspect})"
    end
  end
end
