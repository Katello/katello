class CreateKatelloHostQueueElements < ActiveRecord::Migration[6.0]
  def up
    create_table :katello_host_queue_elements do |t|
      t.integer :host_id
      t.column :created_at, :datetime
    end
  end

  def down
    drop_table :katello_host_queue_elements
  end
end
