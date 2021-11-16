class KatelloPoolOrganizationIdNotNullable < ActiveRecord::Migration[6.0]
  def up
    ::Katello::Pool.where(organization_id: nil).destroy_all
    ::Katello::Pool.where(subscription_id: nil).destroy_all

    change_column :katello_pools, :organization_id, :integer, null: false
    change_column :katello_pools, :subscription_id, :integer, null: false

    add_index :katello_pools, :organization_id
  end

  def down
    change_column :katello_pools, :organization_id, :integer, null: true
    change_column :katello_pools, :subscription_id, :integer, null: true

    remove_index :katello_pools, :organization_id
  end
end
