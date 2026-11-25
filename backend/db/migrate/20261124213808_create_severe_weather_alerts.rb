class CreateSevereWeatherAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :severe_weather_alerts do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :location, null: false, foreign_key: true
      t.string :event, null: false
      t.datetime :sent_at

      t.timestamps

      t.index [:user_id, :location_id, :event, :created_at]
      t.index :created_at, where: 'sent_at IS NULL', name: 'index_severe_weather_alerts_on_unsent'
    end
  end
end
