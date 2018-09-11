class AddForeignKeyToHypervisorId < ActiveRecord::Migration[5.1]
  def up
    # Update all pools that have a hypervisor reference that's not a host before we add the FK
    ::Katello::Pool.where.not(hypervisor_id: nil).where.not(hypervisor_id: Host::Managed.all).update_all(hypervisor_id: nil)

    add_foreign_key(:katello_pools, :hosts,
                    :name => 'katello_pools_hypervisor_fk', :column => 'hypervisor_id')
  end

  def down
    remove_foreign_key(:katello_pools, :name => 'katello_pools_hypervisor_fk')
  end
end
