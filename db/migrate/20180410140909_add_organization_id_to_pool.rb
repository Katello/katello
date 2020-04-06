class AddOrganizationIdToPool < ActiveRecord::Migration[5.1]
  def up
    add_column :katello_pools, :organization_id, :integer
    add_foreign_key 'katello_pools', 'taxonomies',
                :name => 'katello_pools_organization_id', :column => 'organization_id'

    ::Katello::Pool.reset_column_information
    ::Katello::Pool.find_each do |pool|
      pool.update(:organization_id => pool.subscription.organization_id) if pool.subscription
    end
  end

  def down
    remove_column :katello_pools, :organization_id
  end
end
