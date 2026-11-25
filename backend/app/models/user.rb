class User < ApplicationRecord
  has_many :user_favorites, dependent: :destroy
end
