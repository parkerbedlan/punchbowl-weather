require 'test_helper'

class Api::CurrentUsersControllerTest < ActionDispatch::IntegrationTest
  test 'show returns the id and the role of the first user' do
    users(:current).update!(role: :admin)

    get api_current_user_path, as: :json

    assert_response :success
    assert_equal({ 'id' => users(:current).id, 'role' => 'admin' }, response.parsed_body)
  end

  test 'a new user is a member' do
    get api_current_user_path, as: :json

    assert_equal 'member', response.parsed_body['role']
  end

  test 'show returns not found when there is no user' do
    User.destroy_all

    get api_current_user_path, as: :json

    assert_response :not_found
  end
end
