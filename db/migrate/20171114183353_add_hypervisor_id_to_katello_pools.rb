class AddHypervisorIdToKatelloPools < ActiveRecord::Migration
  def up
    add_column :katello_pools, :hypervisor_id, :integer
  end

  def down
    remove_column :katello_pools, :hypervisor_id
  end
end
