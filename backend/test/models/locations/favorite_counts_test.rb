require 'test_helper'

class Locations::FavoriteCountsTest < ActiveSupport::TestCase
  NOON_TODAY = Time.utc(2026, 11, 25, 12)

  setup { travel_to NOON_TODAY }

  test "the days are the last 30 days and end today" do
    days = favorite_counts[:days]

    assert_equal 30, days.size
    assert_equal ['2026-10-27', '2026-11-25'], [days.first, days.last]
  end

  test "a favorite counts from the day of the favorite" do
    favorite(locations(:new_york), at: Time.utc(2026, 11, 22, 23, 59))

    assert_equal ([0] * 26) + [1, 1, 1, 1], counts_for(locations(:new_york))
  end

  test "an unfavorite lowers the count from the day of the unfavorite" do
    travel_to(Time.utc(2026, 11, 24, 0, 1)) { user_favorites(:current_boston).destroy! }

    assert_equal ([1] * 28) + [0, 0], counts_for(locations(:boston))
  end

  test "a favorite with no event counts for each day" do
    assert_equal [1] * 30, counts_for(locations(:boston))
  end

  test "each user with the favorite adds to the count" do
    favorite(locations(:boston), at: 10.days.ago)
    favorite(locations(:boston), at: 2.days.ago)

    assert_equal ([1] * 19) + ([2] * 8) + [3, 3, 3], counts_for(locations(:boston))
  end

  test "a location with no favorite in the last 30 days is left out" do
    user_favorite = favorite(locations(:new_york), at: 40.days.ago)
    travel_to(35.days.ago) { user_favorite.destroy! }

    assert_equal ['Boston, Massachusetts'], location_names
  end

  test "the locations are in the order of the count now and then the name" do
    albany = Location.create!(name: 'Albany, New York', slug: 'albany_new_york')
    favorite(albany, at: 1.day.ago)
    2.times { favorite(locations(:new_york), at: 1.day.ago) }

    assert_equal ['New York, New York', 'Albany, New York', 'Boston, Massachusetts'], location_names
  end

  test "an event for a deleted location is left out" do
    AuditEvent.create!(action: :favorite, data: { user_id: users(:current).id, location_id: 0 })

    assert_equal ['Boston, Massachusetts'], location_names
  end

  private

  def favorite(location, at:)
    User.create!.user_favorites.create!(location:, created_at: at)
  end

  def favorite_counts
    Locations::FavoriteCounts.new.as_json
  end

  def counts_for(location)
    favorite_counts[:locations].find { it[:id] == location.id }.fetch(:counts)
  end

  def location_names
    favorite_counts[:locations].pluck(:name)
  end
end
