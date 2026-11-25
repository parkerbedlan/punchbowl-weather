require 'test_helper'

class Api::Admin::LocationFavoriteCountsControllerTest < ActionDispatch::IntegrationTest
  test 'index returns the daily favorite counts to an admin' do
    travel_to Time.utc(2026, 11, 25, 12)
    users(:current).update!(role: :admin)

    get api_admin_location_favorite_counts_path, as: :json

    assert_response :success
    assert_equal '2026-10-27', response.parsed_body['days'].first
    assert_equal '2026-11-25', response.parsed_body['days'].last
    assert_equal(
      [{ 'id' => locations(:boston).id, 'slug' => 'boston', 'name' => 'Boston, Massachusetts', 'counts' => [1] * 30 }],
      response.parsed_body['locations']
    )
  end

  test 'index returns forbidden to a member' do
    get api_admin_location_favorite_counts_path, as: :json

    assert_response :forbidden
    assert_empty response.body
  end

  test 'index returns forbidden when there is no user' do
    User.destroy_all

    get api_admin_location_favorite_counts_path, as: :json

    assert_response :forbidden
  end
end
