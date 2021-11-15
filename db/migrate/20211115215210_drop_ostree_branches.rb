class DropOstreeBranches < ActiveRecord::Migration[6.0]
  def up
    drop_table :katello_repository_ostree_branches
    drop_table :katello_ostree_branches

    remove_column :katello_root_repositories, :ostree_upstream_sync_policy
    remove_column :katello_root_repositories, :ostree_upstream_sync_depth
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
