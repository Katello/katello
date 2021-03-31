class KatelloPoolOrganizationIdNotNullable < ActiveRecord::Migration[6.0]
  def change
    ::Katello::Pool.where(organization_id: nil).destroy_all
    change_column :katello_pools, :organization_id, :integer, null: false
  end
end
