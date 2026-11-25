class AddLocationForeignKeyAndUniqueIndexToUserFavorites < ActiveRecord::Migration[8.1]
  def change
    remove_index :user_favorites, [:user_id, :location_id]
    add_index :user_favorites, [:user_id, :location_id], unique: true
    add_foreign_key :user_favorites, :locations
  end
end
