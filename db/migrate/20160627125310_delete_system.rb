class DeleteSystem < ActiveRecord::Migration[4.2]
  def change
    drop_table :katello_system_activation_keys
    drop_table :katello_system_repositories
    drop_table :katello_systems
  end
end
