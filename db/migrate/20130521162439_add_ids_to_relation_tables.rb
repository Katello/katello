class AddIdsToRelationTables < ActiveRecord::Migration
  def up
    add_column :content_view_version_environments, :id, :primary_key
    add_column :roles_users, :id, :primary_key

    remove_index :content_view_version_environments, :name => 'cvv_env_index'
    add_index :content_view_version_environments, [:content_view_version_id, :environment_id],
              :name => 'cvv_env_index', :unique => true
  end

  def down
    remove_column :content_view_version_environments, :id
    remove_column :roles_users, :id

    remove_index :content_view_version_environments, :name => 'cvv_env_index'
    add_index :content_view_version_environments, [:content_view_version_id, :environment_id],
              :name => 'cvv_env_index'
  end
end
