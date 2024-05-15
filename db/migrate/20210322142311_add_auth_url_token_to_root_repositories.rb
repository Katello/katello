class AddAuthURLTokenToRootRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_root_repositories, :ansible_collection_auth_url, :text
    add_column :katello_root_repositories, :ansible_collection_auth_token, :text
  end
end
