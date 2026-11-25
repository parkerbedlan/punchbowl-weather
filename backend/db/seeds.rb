# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

[
  { slug: 'new_york',    name: 'New York, New York',      lat: 40.7128, lon:  -74.0060 },
  { slug: 'boston',      name: 'Boston, Massachusetts',   lat: 42.3601, lon:  -71.0589 },
  { slug: 'chicago',     name: 'Chicago, Illinois',       lat: 41.8781, lon:  -87.6298 },
  { slug: 'denver',      name: 'Denver, Colorado',        lat: 39.7392, lon: -104.9903 },
  { slug: 'houston',     name: 'Houston, Texas',          lat: 29.7604, lon:  -95.3698 },
  { slug: 'seattle',     name: 'Seattle, Washington',     lat: 47.6062, lon: -122.3321 },
  { slug: 'los_angeles', name: 'Los Angeles, California', lat: 34.0522, lon: -118.2437 }
].each do |attributes|
  Location.find_or_create_by!(slug: attributes[:slug]) do |location|
    location.assign_attributes(attributes)
  end
end

User.first_or_create!
