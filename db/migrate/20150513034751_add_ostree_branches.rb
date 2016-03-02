class AddOstreeBranches < ActiveRecord::Migration
  def up
    create_table :katello_ostree_branches do |t|
      t.string :name, :null => false, :limit => 255
      t.references :repository, :null => false
      t.timestamps
    end

    add_index :katello_ostree_branches, [:repository_id],
              :name => :index_branches_on_repository

    add_foreign_key :katello_ostree_branches,
                    :katello_repositories,
                    :column => "repository_id",
                    :name => "katello_ostree_branches_repository_id_fk"

    add_index :katello_ostree_branches, [:repository_id, :name],
              :name => :katello_ostree_branches_repo_branch, :unique => true
  end

  def down
    remove_foreign_key :katello_ostree_branches, :name => "katello_ostree_branches_repository_id_fk"
    drop_table :katello_ostree_branches
  end
end
