require 'test_helper'

class AuditEventTest < ActiveSupport::TestCase
  test "a saved audit event refuses a change" do
    audit_event = AuditEvent.create!(action: :favorite, data: { user_id: 1, location_id: 2 })

    assert_raises(ActiveRecord::ReadOnlyRecord) { audit_event.update!(action: :unfavorite) }
    assert_raises(ActiveRecord::ReadOnlyRecord) { audit_event.destroy! }
  end
end
