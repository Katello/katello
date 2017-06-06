class ProviderAddDiscoveryTaskId < ActiveRecord::Migration
  def self.up
    add_column :providers, :discovery_task_id, :integer, :default=>nil
  end

  def self.down
    remove_column :providers, :discovery_task_id
  end
end
