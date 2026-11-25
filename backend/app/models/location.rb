class Location < ApplicationRecord
  include Locations::WeatherRefresh
  include Locations::SevereWeather

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  def self.list
    order(:id)
  end

  def self.get(slug)
    find_by(slug: slug)
  end

  def self.find_or_create_for_place(city:, country:, state: nil)
    name = Locations::Candidate.new(city:, state:, country:).name
    location = find_by(name:)
    return location if location

    candidate = Locations::Candidate.find(city:, state:, country:)
    return if candidate.nil?

    create_named(name, lat: candidate.lat, lon: candidate.lon)
  end

  def self.create_named(name, lat:, lon:)
    create!(name:, slug: name.parameterize.underscore, lat:, lon:)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    find_by(name:) || raise
  end
  private_class_method :create_named
end
