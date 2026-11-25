module SavedWeather
  def save_weather(location, condition_ids:, wind_speed: 5, fetched_at: Time.current)
    location.update!(
      weather_data: open_weather_payload_with(condition_ids:, wind_speed:),
      weather_fetched_at: fetched_at,
      weather_refresh_after: fetched_at + Locations::WeatherRefresh::WEATHER_FRESH_FOR
    )
  end

  def open_weather_payload_with(condition_ids:, wind_speed: 5)
    open_weather_payload.merge(
      'weather' => condition_ids.map { |condition_id| { 'id' => condition_id } },
      'wind' => { 'speed' => wind_speed }
    )
  end
end
