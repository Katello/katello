class RemoveEventDaemonTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :katello_events
    drop_table :katello_host_queue_elements
  end

  def down
    create_table :katello_events do |t|
      t.integer :object_id, null: false
      t.string :event_type, null: false
      t.boolean :in_progress, default: false, null: false
      t.text :metadata
      t.datetime :process_after
      t.timestamps
    end
    add_index :katello_events, [:object_id, :event_type, :in_progress, :created_at], name: :katello_events_oid_et_ip_ca

    create_table :katello_host_queue_elements do |t|
      t.integer :host_id
      t.datetime :created_at
    end
  end
end
