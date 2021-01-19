class AddModularToInstalledPackages < ActiveRecord::Migration[6.0]
  def up
    add_column :katello_installed_packages, :modular, :boolean
  end

  def down
    remove_column :katello_installed_packages, :modular
  end
end
