class CreateOpenWeatherAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :open_weather_accounts do |t|
      t.datetime :calls_paused_until

      t.timestamps
    end
  end
end
