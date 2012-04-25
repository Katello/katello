class RemoveAllocatedFromKeyPools < ActiveRecord::Migration
  def self.up
    remove_column :key_pools, :allocated
  end

  def self.down
    add_column :key_pools, :allocated, :integer
  end
end
