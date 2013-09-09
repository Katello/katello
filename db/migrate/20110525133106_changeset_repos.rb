class ChangesetRepos < ActiveRecord::Migration
  def self.up
    create_table :changesets_repositories, :id => false do |t|
      t.references :changeset, :null => false
      t.references :repository, :null => false
    end
  end

  def self.down
    drop_table :changesets_repositories
  end
end
