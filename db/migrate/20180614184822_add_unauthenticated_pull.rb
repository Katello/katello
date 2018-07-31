class AddUnauthenticatedPull < ActiveRecord::Migration[5.1]
  def up
    add_column :katello_environments, :registry_unauthenticated_pull, :boolean, :default => false
  end

  def down
    remove_column :katello_environments, :registry_unauthenticated_pull
  end
end
