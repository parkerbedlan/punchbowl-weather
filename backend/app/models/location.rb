class Location < ApplicationRecord
  include Locations::WeatherRefresh

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true

  def self.list
    order(:id)
  end

  def self.get(slug)
    find_by(slug: slug)
  end

  def self.lookup(lat:, lon:)
    city = Geocoder.search([lat, lon]).first.city
    self.new(city, lat, lon)
  rescue
    nil
  end
end
