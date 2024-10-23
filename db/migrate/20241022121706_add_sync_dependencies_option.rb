class AddSyncDependenciesOption < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_root_repositories, :sync_dependencies, :boolean, :default => true
  end
end
