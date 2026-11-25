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

  test "a new favorite writes a favorite event with the time of the favorite" do
    user_favorite = users(:current).user_favorites.create!(location: locations(:new_york))

    audit_event = AuditEvent.sole
    assert_predicate audit_event, :favorite?
    assert_equal favorite_data(user_favorite), audit_event.data
    assert_equal user_favorite.created_at, audit_event.created_at
  end

  test "a removed favorite writes an unfavorite event" do
    freeze_time

    user_favorites(:current_boston).destroy!

    audit_event = AuditEvent.sole
    assert_predicate audit_event, :unfavorite?
    assert_equal favorite_data(user_favorites(:current_boston)), audit_event.data
    assert_equal Time.current, audit_event.created_at
  end

  private

  def favorite_data(user_favorite)
    { 'user_id' => user_favorite.user_id, 'location_id' => user_favorite.location_id }
  end
end
