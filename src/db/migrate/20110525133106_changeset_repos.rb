class ChangesetRepos < ActiveRecord::Migration
  def self.up
    create_table :changeset_repos do |t|
       t.integer :changeset_id
       t.string :repo_id
       t.string :display_name
       t.references :product, :null=>false
    end
  end

  def self.down
    drop_table :changeset_repos
  end
end
