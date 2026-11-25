class CreateUserFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :user_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :location_id, null: false

      t.timestamps
    end

    add_index :user_favorites, [:user_id, :location_id]
  end
end
