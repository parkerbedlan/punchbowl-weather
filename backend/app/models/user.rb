class User < ApplicationRecord
  enum :role, { member: 'member', admin: 'admin' }

  has_many :user_favorites, dependent: :destroy
  has_many :severe_weather_alerts, dependent: :destroy

  scope :without_recent_severe_weather_alert, ->(location:, event:) {
    where(
      'NOT EXISTS (?)',
      SevereWeatherAlert.recent.where(location:, event:).where('severe_weather_alerts.user_id = users.id')
    )
  }
end
