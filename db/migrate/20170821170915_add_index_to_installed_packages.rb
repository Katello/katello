class AddIndexToInstalledPackages < ActiveRecord::Migration[4.2]
  def change
    add_index :katello_installed_packages, [:name, :nvra]
  end
end
