class AddDepthToRepositories < ActiveRecord::Migration
  def change
    add_column :katello_repositories, :ostree_upstream_sync_policy, :string, :limit => 25
    add_column :katello_repositories, :ostree_upstream_sync_depth, :integer
  end
end
