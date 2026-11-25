class UserFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :location

  after_create :record_favorite
  after_destroy :record_unfavorite

  private

  def record_favorite
    AuditEvent.create!(action: :favorite, data: audit_event_data, created_at:)
  end

  def record_unfavorite
    AuditEvent.create!(action: :unfavorite, data: audit_event_data)
  end

  def audit_event_data
    { user_id:, location_id: }
  end
end
