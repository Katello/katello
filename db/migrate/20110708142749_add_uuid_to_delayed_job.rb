class AddUuidToDelayedJob < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :uuid, :string
    change_column :delayed_jobs, :uuid, :string, :limit => 36, :null => false
    add_index :delayed_jobs, :uuid
  end

  def self.down
    remove_index :delayed_jobs, :uuid
    remove_column :delayed_jobs, :uuid
  end
end
