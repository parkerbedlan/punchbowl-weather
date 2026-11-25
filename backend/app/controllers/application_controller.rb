class ApplicationController < ActionController::API
  private

  # Authentication is out of scope for this challenge, so the first user stands
  # in for the signed-in one. Routing every controller through this method
  # keeps swapping it for a real session lookup a one-line change.
  #
  # NOTE: no users are seeded. Create one before the favorites endpoints will
  # do anything, e.g. `User.create!` from `bin/rails console`.
  def current_user
    @current_user ||= User.first
  end
end
