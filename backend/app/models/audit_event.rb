class AuditEvent < ApplicationRecord
  USER_ID_IN_DATA = "json_extract(data, '$.user_id')".freeze
  LOCATION_ID_IN_DATA = "json_extract(data, '$.location_id')".freeze

  enum :action, {
    favorite: 'favorite',
    unfavorite: 'unfavorite',
    pause_open_weather_calls: 'pause_open_weather_calls'
  }

  def readonly?
    persisted?
  end
end
