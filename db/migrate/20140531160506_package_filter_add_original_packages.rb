class PackageFilterAddOriginalPackages < ActiveRecord::Migration
  def up
    add_column :katello_content_view_filters, :original_packages, :boolean, :default => false, :null => false
  end

  def down
    remove_column :katello_content_view_filters, :original_packages
  end
end
