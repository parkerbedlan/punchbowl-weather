class UserFavorite < ApplicationRecord
  belongs_to :user

  validates :location_id, presence: true
end
