class AddVirtWhoToKatelloPools < ActiveRecord::Migration[4.2]
  def up
    add_column :katello_pools, :virt_who, :boolean, :default => false, :null => false
  end

  def down
    remove_column :katello_pools, :virt_who
  end
end
