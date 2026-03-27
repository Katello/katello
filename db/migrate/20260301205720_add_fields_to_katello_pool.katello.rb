class AddFieldsToKatelloPool < ActiveRecord::Migration[7.0]
  def up
    add_column :katello_pools, :arch, :string
    add_column :katello_pools, :roles, :string
    add_column :katello_pools, :usage, :string
    add_column :katello_pools, :support_type, :string
    add_column :katello_pools, :upstream_entitlement_id, :string
    add_column :katello_pools, :description, :string

    change_column :katello_pools, :multi_entitlement, :boolean, default: false
  end

  def down
    remove_column :katello_pools, :arch
    remove_column :katello_pools, :roles
    remove_column :katello_pools, :usage
    remove_column :katello_pools, :support_type
    remove_column :katello_pools, :upstream_entitlement_id
    remove_column :katello_pools, :description
  end
end
