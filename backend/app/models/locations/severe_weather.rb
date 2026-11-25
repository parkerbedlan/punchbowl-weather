module Locations
  module SevereWeather
    extend ActiveSupport::Concern

    # https://openweathermap.org/weather-conditions
    SEVERE_CONDITION_EVENTS = {
      202 => 'thunderstorm with heavy rain',
      212 => 'heavy thunderstorm',
      503 => 'very heavy rain',
      504 => 'extreme rain',
      511 => 'freezing rain',
      602 => 'heavy snow',
      622 => 'heavy shower snow',
      762 => 'volcanic ash',
      771 => 'squalls',
      781 => 'tornado'
    }.freeze

    # National Weather Service High Wind Warning: "sustained winds of 40 mph or higher for one hour or more"
    # https://www.weather.gov/lwx/WarningsDefined
    HIGH_WIND_SPEED_IN_MILES_PER_HOUR = 40
    WEATHER_TOO_OLD_TO_ALERT_AFTER = 30.minutes

    included do
      has_many :user_favorites
      has_many :favoriting_users, through: :user_favorites, source: :user
      has_many :severe_weather_alerts, dependent: :destroy

      scope :favorited, -> { where(id: UserFavorite.select(:location_id)) }
    end

    def severe_weather_events
      return [] if weather_too_old_to_alert?

      events = weather_data.fetch('weather', []).filter_map { SEVERE_CONDITION_EVENTS[it['id']] }
      events << 'high wind' if weather_data.dig('wind', 'speed').to_f >= HIGH_WIND_SPEED_IN_MILES_PER_HOUR
      events
    end

    private

    def weather_too_old_to_alert?
      weather_fetched_at.nil? || weather_fetched_at < WEATHER_TOO_OLD_TO_ALERT_AFTER.ago
    end
  end
end
