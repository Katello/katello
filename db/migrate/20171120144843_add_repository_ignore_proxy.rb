class AddRepositoryIgnoreProxy < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_repositories, :ignore_global_proxy, :boolean, :null => false, :default => false
  end
end
