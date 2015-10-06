class AddVirtOnlyToKatelloPools < ActiveRecord::Migration
  def up
    add_column :katello_pools, :virt_only, :boolean, :default => false, :null => false
    add_column :katello_pools, :unmapped_guest, :boolean, :default => false, :null => false
  end

  def down
    remove_column :katello_pools, :virt_only
    remove_column :katello_pools, :unmapped_guest
  end
end
