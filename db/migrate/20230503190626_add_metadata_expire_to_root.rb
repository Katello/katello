class AddMetadataExpireToRoot < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_root_repositories, :metadata_expire, :integer
  end
end
