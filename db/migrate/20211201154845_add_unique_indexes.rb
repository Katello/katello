class AddUniqueIndexes < ActiveRecord::Migration[6.0]
  def up
    ::Katello::Util::DeduplicationMigrator.new.execute!
    add_index :katello_capsule_lifecycle_environments, [:capsule_id, :lifecycle_environment_id], unique: true, name: 'katello_capsule_lifecycle_environments_unique_index'
    add_index :katello_content_view_erratum_filter_rules, [:errata_id, :content_view_filter_id], unique: true, name: 'katello_content_view_erratum_filter_rules_unique_index'
    add_index :katello_content_view_module_stream_filter_rules, [:module_stream_id, :content_view_filter_id], unique: true, name: 'katello_content_view_module_stream_filter_rules_unique_index'
    add_index :katello_content_view_package_group_filter_rules, [:uuid, :content_view_filter_id], unique: true, name: 'katello_content_view_package_group_filter_rules_unique_index'
    add_index :katello_content_view_repositories, [:content_view_id, :repository_id], unique: true, name: 'katello_content_view_repositories_unique_index'
    add_index :katello_content_views, [:name, :organization_id], unique: true, name: 'katello_content_views_name_unique_index'
  end

  def down
    remove_index :katello_capsule_lifecycle_environments, name: 'katello_capsule_lifecycle_environments_unique_index'
    remove_index :katello_content_view_erratum_filter_rules, name: 'katello_content_view_erratum_filter_rules_unique_index'
    remove_index :katello_content_view_module_stream_filter_rules, name: 'katello_content_view_module_stream_filter_rules_unique_index'
    remove_index :katello_content_view_package_group_filter_rules, name: 'katello_content_view_package_group_filter_rules_unique_index'
    remove_index :katello_content_view_repositories, name: 'katello_content_view_repositories_unique_index'
    remove_index :katello_content_views, name: 'katello_content_views_name_unique_index'
  end
end
