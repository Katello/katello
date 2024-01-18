class AddIndexToHostInstalledPackages < ActiveRecord::Migration[6.1]
  def up
    add_index :katello_host_installed_packages, [:installed_package_id],
      :name => 'katello_host_installed_packages_ip_id'
    add_index :katello_host_installed_packages, [:host_id],
      :name => 'katello_host_installed_packages_host_id'
  end

  def down
    remove_index :katello_host_installed_packages,
      :name => 'katello_host_installed_packages_ip_id'

    remove_index :katello_host_installed_packages,
      :name => 'katello_host_installed_packages_host_id'
  end
end
