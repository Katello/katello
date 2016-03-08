class AddVersionOstreeBranches < ActiveRecord::Migration
  def up
    drop_table :katello_ostree_branches if ActiveRecord::Base.connection.table_exists? "katello_ostree_branches"

    create_table :katello_ostree_branches do |t|
      t.string :version, :limit => 255
      t.string :name, :limit => 255
      t.string :uuid, :null => false, :limit => 255
      t.string :commit, :limit => 255
      t.timestamp :version_date
      t.timestamps
    end

    create_table :katello_repository_ostree_branches do |t|
      t.references :ostree_branch, :null => false
      t.references :repository, :null => true
      t.timestamps
    end

    add_index :katello_repository_ostree_branches, [:ostree_branch_id, :repository_id],
              :name => :katello_repo_ostree_branch_repo_id, :unique => true

    add_foreign_key :katello_repository_ostree_branches, :katello_repositories,
                    :column => :repository_id
  end

  def down
    drop_table :katello_repository_ostree_branches
    drop_table :katello_ostree_branches
    create_table :katello_ostree_branches do |t|
      t.string :name, :null => false, :limits => 255
      t.references :repository, :null => false
      t.timestamps
    end

    add_index :katello_ostree_branches, [:repository_id],
              :name => :index_branches_on_repository

    add_index :katello_ostree_branches, [:repository_id, :name],
              :name => :katello_ostree_branches_repo_branch, :unique => true
  end
end
