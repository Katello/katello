class AddConstraintsKatelloHostQueueElement < ActiveRecord::Migration[7.0]
  def up
    dups = Katello::HostQueueElement.group(:host_id).select("MIN(id) as id, host_id").having("COUNT(*) > 1")

    dups.each do |dup|
      Katello::HostQueueElement.where.not(id: dup.id).where(host_id: dup.host_id).delete_all
    end

    add_index :katello_host_queue_elements, :host_id, unique: true
  end

  def down
    remove_index :katello_host_queue_elements, :host_id
  end
end
