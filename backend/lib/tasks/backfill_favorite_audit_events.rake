namespace :backfill do
  desc 'Write a favorite event for each favorite that has none. It is safe to run more than once.'
  task favorite_audit_events: :environment do
    latest_event_times = AuditEvent.favorite
                                   .group(AuditEvent::USER_ID_IN_DATA, AuditEvent::LOCATION_ID_IN_DATA)
                                   .maximum(:created_at)
    written_event_count = 0

    UserFavorite.find_each do |user_favorite|
      latest_event_time = latest_event_times[[user_favorite.user_id, user_favorite.location_id]]
      next if latest_event_time && latest_event_time >= user_favorite.created_at

      AuditEvent.create!(
        action: :favorite,
        data: { user_id: user_favorite.user_id, location_id: user_favorite.location_id },
        created_at: user_favorite.created_at
      )
      written_event_count += 1
    end

    puts "Wrote #{written_event_count} favorite #{'event'.pluralize(written_event_count)}."
  end
end
