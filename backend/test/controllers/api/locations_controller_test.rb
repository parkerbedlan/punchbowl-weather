require 'test_helper'

class Api::LocationsControllerTest < ActionDispatch::IntegrationTest
  test 'index returns every location with the fields the frontend reads' do
    get api_locations_path, as: :json

    assert_response :success
    assert_equal(
      [locations(:boston), locations(:new_york)].sort_by(&:id).map { |location|
        { 'id' => location.id, 'slug' => location.slug, 'name' => location.name }
      },
      response.parsed_body
    )
  end

  test 'show returns the location for a slug' do
    get api_location_path(:boston), as: :json

    assert_response :success
    assert_equal(
      { 'id' => locations(:boston).id, 'slug' => 'boston', 'name' => 'Boston, Massachusetts' },
      response.parsed_body
    )
  end

  test 'show for a slug with no location returns not found' do
    get api_location_path(:atlantis), as: :json

    assert_response :not_found
  end
end
