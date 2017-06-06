class AddChangesetsDependencyDependencyOf < ActiveRecord::Migration
  def self.up
    add_column :changeset_dependencies, :dependency_of, :string
  end

  def self.down
    remove_column :changeset_dependencies, :dependency_of
  end
end
