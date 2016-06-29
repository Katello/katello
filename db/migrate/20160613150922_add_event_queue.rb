class AddEventQueue < ActiveRecord::Migration
  def change
    create_table :katello_events, :force => true do |t|
      t.integer :object_id, :null => false
      t.string :event_type, :null => false
      t.boolean :in_progress, :default => false, :null => false
      t.timestamps
    end

    add_index :katello_events, [:object_id, :event_type, :in_progress, :created_at], :name => :katello_events_oid_et_ip_ca
  end
end
