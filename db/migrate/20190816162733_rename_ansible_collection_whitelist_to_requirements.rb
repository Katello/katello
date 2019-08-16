class RenameAnsibleCollectionWhitelistToRequirements < ActiveRecord::Migration[5.2]
  def change
    rename_column :katello_root_repositories, :ansible_collection_whitelist, :ansible_collection_requirements
  end
end
