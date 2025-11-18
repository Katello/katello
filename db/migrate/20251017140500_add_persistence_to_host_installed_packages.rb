class AddPersistenceToHostInstalledPackages < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_host_installed_packages, :persistence, :string, null: true, default: nil
    add_check_constraint :katello_host_installed_packages, "persistence IN ('transient', 'persistent') OR persistence IS NULL", name: 'check_persistence_values'
  end
end
