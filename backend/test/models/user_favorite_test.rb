require 'test_helper'

class UserFavoriteTest < ActiveSupport::TestCase
  test "a user can favorite more than one location" do
    users(:current).user_favorites.create!(location: locations(:new_york))

    assert_equal 2, users(:current).user_favorites.count
  end

  test "a favorite needs a location" do
    favorite = users(:current).user_favorites.build

    assert_not favorite.valid?
    assert_includes favorite.errors[:location], 'must exist'
  end

  test "a user cannot favorite the same location twice" do
    assert_raises ActiveRecord::RecordNotUnique do
      users(:current).user_favorites.create!(location: locations(:boston))
    end
  end
end
