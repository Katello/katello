class AddAnsibleCollectionWhitelistToKatelloRootRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_root_repositories, :ansible_collection_whitelist, :string
  end
end
