require 'test_helper'
require 'rake'

class BackfillFavoriteAuditEventsTest < ActiveSupport::TestCase
  TASK_NAME = 'backfill:favorite_audit_events'.freeze

  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?(TASK_NAME)
  end

  test "the backfill writes a favorite event for a favorite that has none" do
    assert_output("Wrote 1 favorite event.\n") { run_backfill }

    audit_event = AuditEvent.sole
    assert_predicate audit_event, :favorite?
    assert_equal favorite_data(user_favorites(:current_boston)), audit_event.data
    assert_equal user_favorites(:current_boston).created_at, audit_event.created_at
  end

  test "the backfill writes no second event for a favorite" do
    users(:current).user_favorites.create!(location: locations(:new_york))

    assert_output("Wrote 1 favorite event.\n") { run_backfill }
    assert_output("Wrote 0 favorite events.\n") { run_backfill }

    assert_equal 2, AuditEvent.favorite.count
  end

  test "the backfill writes an event for a favorite made again with no event" do
    user_favorites(:current_boston).update!(created_at: 1.day.ago)
    AuditEvent.create!(action: :favorite, data: favorite_data(user_favorites(:current_boston)), created_at: 10.days.ago)
    AuditEvent.create!(action: :unfavorite, data: favorite_data(user_favorites(:current_boston)), created_at: 5.days.ago)

    assert_output("Wrote 1 favorite event.\n") { run_backfill }

    assert_equal user_favorites(:current_boston).created_at, AuditEvent.favorite.maximum(:created_at)
  end

  private

  def run_backfill
    Rake::Task[TASK_NAME].reenable
    Rake::Task[TASK_NAME].invoke
  end

  def favorite_data(user_favorite)
    { 'user_id' => user_favorite.user_id, 'location_id' => user_favorite.location_id }
  end
end
