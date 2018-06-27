class AddUpstreamPoolIdToKatelloPool < ActiveRecord::Migration[5.1]
  def up
    add_column :katello_pools, :upstream_pool_id, :string
  end

  def down
    remove_column :katello_pools, :upstream_pool_id
  end
end
