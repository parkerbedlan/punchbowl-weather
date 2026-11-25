require 'test_helper'

class Api::UserFavoritesControllerTest < ActionDispatch::IntegrationTest
  test 'index returns the favorites of the first user' do
    get api_user_favorites_path, as: :json

    assert_response :success
    assert_equal [locations(:boston).id], response.parsed_body.map { |favorite| favorite['location_id'] }
  end

  test 'index returns an empty list when there is no user' do
    User.destroy_all

    get api_user_favorites_path, as: :json

    assert_response :success
    assert_equal [], response.parsed_body
  end

  test 'create adds a favorite' do
    assert_difference -> { users(:current).user_favorites.count }, 1 do
      post api_user_favorites_path, params: { location_id: locations(:new_york).id }, as: :json
    end

    assert_response :created
    assert_equal locations(:new_york).id, response.parsed_body['location_id']
  end

  test 'create returns the existing favorite for a location that is already one' do
    assert_no_difference -> { UserFavorite.count } do
      post api_user_favorites_path, params: { location_id: locations(:boston).id }, as: :json
    end

    assert_response :ok
    assert_equal user_favorites(:current_boston).id, response.parsed_body['id']
  end

  test 'create writes no audit event for a location that is already a favorite' do
    assert_no_difference -> { AuditEvent.count } do
      post api_user_favorites_path, params: { location_id: locations(:boston).id }, as: :json
    end
  end

  test 'create returns not found for a location that does not exist' do
    assert_no_difference -> { UserFavorite.count } do
      post api_user_favorites_path, params: { location_id: 0 }, as: :json
    end

    assert_response :not_found
  end

  test 'create returns not found when there is no user' do
    User.destroy_all

    post api_user_favorites_path, params: { location_id: locations(:boston).id }, as: :json

    assert_response :not_found
  end

  test 'destroy removes the favorite for the location' do
    assert_difference -> { users(:current).user_favorites.count }, -1 do
      delete api_user_favorite_path(locations(:boston).id), as: :json
    end

    assert_response :no_content
  end

  test 'destroy returns no content for a location that is not a favorite' do
    assert_no_difference -> { UserFavorite.count } do
      delete api_user_favorite_path(locations(:new_york).id), as: :json
    end

    assert_response :no_content
  end

  test 'destroy returns not found when there is no user' do
    User.destroy_all

    delete api_user_favorite_path(locations(:boston).id), as: :json

    assert_response :not_found
  end
end
