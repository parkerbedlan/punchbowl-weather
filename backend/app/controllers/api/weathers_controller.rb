class Api::WeathersController < ApplicationController
  def show
    location = Location.get(params[:location_id])
    return head :not_found if location.nil?

    location.refresh_weather_if_due
    return head :service_unavailable if location.weather_data.nil?

    render json: weather_fields(location)
  end

  private

  def weather_fields(location)
    weather = location.weather_data

    {
      temperature: weather.dig('main', 'temp'),
      feels_like: weather.dig('main', 'feels_like'),
      wind_speed: weather.dig('wind', 'speed'),
      humidity: weather.dig('main', 'humidity'),
      description: weather.dig('weather', 0, 'description'),
      icon_uri: weather.dig('weather', 0, 'icon_uri'),
      fetched_at: location.weather_fetched_at
    }
  end
end
