class AddIndexToInstalledPackages < ActiveRecord::Migration
  def change
    add_index :katello_installed_packages, [:name, :nvra]
  end
end
