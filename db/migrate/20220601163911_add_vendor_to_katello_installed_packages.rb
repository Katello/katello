class AddVendorToKatelloInstalledPackages < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_installed_packages, :vendor, :string
  end
end
