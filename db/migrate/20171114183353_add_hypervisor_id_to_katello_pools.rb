class AddHypervisorIdToKatelloPools < ActiveRecord::Migration[4.2]
  def up
    add_column :katello_pools, :hypervisor_id, :integer
  end

  def down
    remove_column :katello_pools, :hypervisor_id
  end
end
