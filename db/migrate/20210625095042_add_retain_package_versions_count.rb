class AddRetainPackageVersionsCount < ActiveRecord::Migration[5.2]
  def up
    add_column :katello_root_repositories, :retain_package_versions_count, :integer
  end

  def down
    remove_column :katello_root_repositories, :retain_package_versions_count
  end
end
