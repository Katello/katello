class AddDistributionsToRepository < ActiveRecord::Migration
  def change
    add_column :katello_repositories, :distribution_version, :string
    add_column :katello_repositories, :distribution_arch, :string
    add_column :katello_repositories, :distribution_bootable, :boolean
    add_column :katello_repositories, :distribution_family, :string
    add_column :katello_repositories, :distribution_variant, :string
    add_column :katello_repositories, :distribution_uuid, :string
  end
end
