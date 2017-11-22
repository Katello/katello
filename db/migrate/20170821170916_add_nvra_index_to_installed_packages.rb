class AddNvraIndexToInstalledPackages < ActiveRecord::Migration[4.2]
  def change
    add_index :katello_installed_packages, [:nvra]
  end
end
