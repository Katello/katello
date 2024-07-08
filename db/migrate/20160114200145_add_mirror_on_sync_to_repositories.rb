class AddMirrorOnSyncToRepositories < ActiveRecord::Migration[4.2]
  class RepositoryMirrorOnSync < ApplicationRecord
    self.table_name = "katello_repositories"
  end

  def change
    add_column :katello_repositories, :mirror_on_sync, :boolean, :default => true, :null => false
    RepositoryMirrorOnSync.update_all(:mirror_on_sync => false)
  end
end
