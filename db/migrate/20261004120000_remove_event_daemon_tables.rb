class RemoveEventDaemonTables < ActiveRecord::Migration[7.0]
  def up
    schedule_pending_applicability
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

  private

  def schedule_pending_applicability
    return unless table_exists?(:katello_host_queue_elements)

    host_ids = select_values(<<~SQL).map(&:to_i)
      SELECT DISTINCT host_id
      FROM katello_host_queue_elements
      WHERE host_id IS NOT NULL
      ORDER BY host_id
    SQL
    return if host_ids.empty?

    batch_size = [Setting["applicability_batch_size"].to_i, 1].max
    ::User.as_anonymous_admin do
      host_ids.each_slice(batch_size) do |batch|
        ForemanTasks.async_task(::Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: batch)
      end
    end
  end
end
