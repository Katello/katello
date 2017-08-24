class AddNvraIndexToInstalledPackages < ActiveRecord::Migration
  def change
    add_index :katello_installed_packages, [:nvra]
  end
end
