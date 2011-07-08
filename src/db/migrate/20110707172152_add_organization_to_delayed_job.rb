class AddOrganizationToDelayedJob < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :organization_id, :integer
    change_column :delayed_jobs, :organization_id, :integer, :null => false
  end

  def self.down
    remove_column :delayed_jobs, :organization_id
  end
end
