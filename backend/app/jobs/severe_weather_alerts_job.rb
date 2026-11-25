class SevereWeatherAlertsJob < ApplicationJob
  def perform
    Location.favorited.find_each do |location|
      location.refresh_weather_if_due
      SevereWeatherAlert.create_for_favoriting_users(location)
    end

    SevereWeatherAlert.unsent.find_each(&:send_to_user)
  end
end
