class AddDistributionsToRepository < ActiveRecord::Migration
  def change
    add_column :katello_repositories, :distribution_version, :string, :limit => 255
    add_column :katello_repositories, :distribution_arch, :string, :limit => 255
    add_column :katello_repositories, :distribution_bootable, :boolean
    add_column :katello_repositories, :distribution_family, :string, :limit => 255
    add_column :katello_repositories, :distribution_variant, :string, :limit => 255
    add_column :katello_repositories, :distribution_uuid, :string, :limit => 255
  end
end
