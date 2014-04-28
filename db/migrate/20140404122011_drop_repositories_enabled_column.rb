class DropRepositoriesEnabledColumn < ActiveRecord::Migration
  def up
    remove_column :katello_repositories, :enabled
  end

  def down
    add_column :katello_repositories,  :enabled, :boolean, :default => true
  end
end
