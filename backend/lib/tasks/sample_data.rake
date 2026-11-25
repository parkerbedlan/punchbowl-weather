namespace :sample_data do
  desc 'Create sample users with favorites and unfavorites across the last 45 days. Each run adds more.'
  task favorites: :environment do
    abort 'This task does not run in production.' if Rails.env.production?

    locations = Location.list.to_a
    abort 'Run bin/rails db:seed first. There are no locations.' if locations.empty?

    random = Random.new(User.count)
    more_popular_first = locations.each_with_index.flat_map { |location, index| [location] * (locations.size - index) }

    60.times do
      user = User.create!

      more_popular_first.sample(3, random:).uniq.each do |location|
        favorited_at = random.rand(45.0).days.ago

        if random.rand < 0.3
          data = { user_id: user.id, location_id: location.id }
          AuditEvent.create!(action: :favorite, data:, created_at: favorited_at)
          AuditEvent.create!(action: :unfavorite, data:, created_at: favorited_at + random.rand(Time.current - favorited_at))
        else
          user.user_favorites.create!(location:, created_at: favorited_at)
        end
      end
    end

    puts "Created 60 sample users. #{UserFavorite.count} favorites are active now."
  end
end
