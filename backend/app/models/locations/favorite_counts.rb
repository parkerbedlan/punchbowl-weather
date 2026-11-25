module Locations
  class FavoriteCounts
    DAY_COUNT = 30

    def initialize
      last_day = Date.current
      @days = (last_day - (DAY_COUNT - 1))..last_day
    end

    def as_json(*)
      { days: days.map(&:iso8601), locations: location_rows }
    end

    private

    attr_reader :days

    def location_rows
      rows = Location.where(id: counts_now.keys | changes_by_day.keys.map(&:first)).map do |location|
        { id: location.id, slug: location.slug, name: location.name, counts: daily_counts(location.id) }
      end

      rows.select { it[:counts].any?(&:positive?) }.sort_by { [-it[:counts].last, it[:name]] }
    end

    def daily_counts(location_id)
      count = counts_now.fetch(location_id, 0)
      counts_from_last_day = days.reverse_each.map do |day|
        count_at_end_of_day = count
        count -= changes_by_day[[location_id, day.iso8601]]
        count_at_end_of_day
      end

      counts_from_last_day.reverse
    end

    def counts_now
      @counts_now ||= UserFavorite.group(:location_id).count
    end

    def changes_by_day
      @changes_by_day ||= begin
        event_counts = AuditEvent.where(action: %i[favorite unfavorite], created_at: days.first.beginning_of_day..)
                                 .group(AuditEvent::LOCATION_ID_IN_DATA, 'date(created_at)', :action)
                                 .count

        event_counts.each_with_object(Hash.new(0)) do |((location_id, day, action), event_count), changes|
          changes[[location_id, day]] += action == 'favorite' ? event_count : -event_count
        end
      end
    end
  end
end
