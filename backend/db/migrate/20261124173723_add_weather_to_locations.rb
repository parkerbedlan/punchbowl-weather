class AddWeatherToLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :weather_data, :json
    add_column :locations, :weather_fetched_at, :datetime
    add_column :locations, :weather_refresh_after, :datetime
  end
end
