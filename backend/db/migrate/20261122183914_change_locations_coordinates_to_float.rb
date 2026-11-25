class ChangeLocationsCoordinatesToFloat < ActiveRecord::Migration[8.1]
  def up
    change_column :locations, :lat, :float
    change_column :locations, :lon, :float
  end

  def down
    change_column :locations, :lat, :string
    change_column :locations, :lon, :string
  end
end
