class AddForeignKeyToHypervisorId < ActiveRecord::Migration[5.1]
  def up
    add_foreign_key(:katello_pools, :hosts,
                    :name => 'katello_pools_hypervisor_fk', :column => 'hypervisor_id')
  end

  def down
    remove_foreign_key(:katello_pools, :name => 'katello_pools_hypervisor_fk')
  end
end
