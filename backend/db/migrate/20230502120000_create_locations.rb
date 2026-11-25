class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string  :lat
      t.string  :lon

      t.timestamps
    end
  end
end
