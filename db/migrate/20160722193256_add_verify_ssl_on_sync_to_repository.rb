class AddVerifySslOnSyncToRepository < ActiveRecord::Migration
  def up
    add_column :katello_repositories, :verify_ssl_on_sync, :boolean, :null => false, :default => true
  end

  def down
    remove_column :katello_repositories, :verify_ssl_on_sync
  end
end
