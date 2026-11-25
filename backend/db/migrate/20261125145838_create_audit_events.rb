class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_events do |t|
      t.string :action, null: false
      t.json :data, null: false
      t.datetime :created_at, null: false

      t.index [:action, :created_at]
    end
  end
end
