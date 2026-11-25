class ApplicationController < ActionController::API
  rescue_from(OpenWeatherAccount::CallsPaused) { head :service_unavailable }

  private

  # Authentication is out of scope for this challenge, so the first user stands
  # in for the signed-in one. Routing every controller through this method
  # keeps swapping it for a real session lookup a one-line change.
  #
  # NOTE: `bin/rails db:seed` creates that first user.
  def current_user
    @current_user ||= User.first
  end
end
