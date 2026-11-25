class SevereWeatherAlert < ApplicationRecord
  REPEAT_AFTER = 6.hours

  belongs_to :user
  belongs_to :location

  validates :event, presence: true

  scope :unsent, -> { where(sent_at: nil) }
  scope :recent, -> { where(created_at: REPEAT_AFTER.ago..) }

  def self.create_for_favoriting_users(location)
    location.severe_weather_events.each do |event|
      location.favoriting_users.without_recent_severe_weather_alert(location:, event:).find_each do |user|
        create!(user:, location:, event:)
      end
    end
  end

  def send_to_user
    Notifier.notify(user_id, "Severe weather in #{location.name}: #{event}.")
    update!(sent_at: Time.current)
  end
end
