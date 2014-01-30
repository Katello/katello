class AddForeignKeysEngine < ActiveRecord::Migration

  def change
    add_foreign_key "katello_activation_keys", "katello_content_views", :column => 'content_view_id', :name => "activation_keys_content_view_id_fk"
    add_foreign_key "katello_activation_keys", "katello_environments", :column => 'environment_id', :name => "activation_keys_environment_id_fk"
    add_foreign_key "katello_activation_keys", "users", :column => 'user_id', :name => "activation_keys_user_id_fk"

    add_foreign_key "katello_changeset_content_views", "katello_changesets", :column => 'changeset_id', :name => "changeset_content_views_changeset_id_fk"
    add_foreign_key "katello_changeset_content_views", "katello_content_views", :column => 'content_view_id', :name => "changeset_content_views_content_view_id_fk"

    add_foreign_key "katello_changeset_users", "katello_changesets", :column => 'changeset_id', :name => "changeset_users_changeset_id_fk"
    add_foreign_key "katello_changeset_users", "users", :column => 'user_id', :name => "changeset_users_user_id_fk"

    add_foreign_key "katello_changesets", "katello_environments", :column => 'environment_id', :name => "changesets_environment_id_fk"
    add_foreign_key "katello_changesets", "katello_task_statuses", :column => 'task_status_id', :name => "changesets_task_status_id_fk"

    add_foreign_key "katello_component_content_views", "katello_content_view_definition_bases",
                            :name => "component_content_views_content_view_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key "katello_component_content_views", "katello_content_views", :name => "component_content_views_content_view_id_fk", :column => "content_view_id"

    add_foreign_key "katello_content_view_definition_bases", "katello_content_view_definition_bases",
                            :name => "content_view_definition_bases_source_id_fk", :column => "source_id"

    add_foreign_key "katello_content_view_definition_products", "katello_content_view_definition_bases",
                            :name => "content_view_definition_products_content_view_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key "katello_content_view_definition_products", "katello_products",
                            :name => "content_view_definition_products_product_id_fk", :column => "product_id"

    add_foreign_key "katello_content_view_definition_repositories", "katello_content_view_definition_bases",
                            :name => "CV_definition_repositories_CV_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key "katello_content_view_definition_repositories", "katello_repositories",
                            :name => "content_view_definition_repositories_repository_id_fk", :column => "repository_id"

    add_foreign_key "katello_content_view_environments", "katello_content_views",
                             :name => "content_view_environments_content_view_id_fk", :column => "content_view_id"
    add_foreign_key "katello_content_view_environments", "katello_environments", :name => "content_view_environments_environment_id_fk", :column => "environment_id"

    add_foreign_key "katello_content_view_version_environments", "katello_content_view_versions",
                            :name => "content_view_version_environments_content_view_version_id_fk", :column => "content_view_version_id"
    add_foreign_key "katello_content_view_version_environments", "katello_environments",
                            :name => "content_view_version_environments_environment_id_fk", :column => "environment_id"

    add_foreign_key "katello_content_view_versions", "katello_content_view_definition_bases", :name => "content_view_versions_content_view_definition_archive_id_fk", :column => "definition_archive_id"
    add_foreign_key "katello_content_view_versions", "katello_content_view_definition_bases", :name => "content_view_versions_definition_archive_id_fk", :column => "definition_archive_id"
    add_foreign_key "katello_content_view_versions", "katello_content_views", :name => "content_view_versions_content_view_id_fk", :column => "content_view_id"

    add_foreign_key "katello_content_views", "katello_content_view_definition_bases", :name => "content_views_content_view_definition_id_fk", :column => "content_view_definition_id"

    add_foreign_key "katello_distributors", "katello_content_views", :name => "distributors_content_view_id_fk", :column => 'content_view_id'
    add_foreign_key "katello_distributors", "katello_environments", :name => "distributors_environment_id_fk", :column => "environment_id"

    add_foreign_key "katello_environment_priors", "katello_environments", :name => "environment_priors_environment_id_fk", :column => 'environment_id'
    add_foreign_key "katello_environment_priors", "katello_environments", :name => "environment_priors_prior_id_fk", :column => "prior_id"

    add_foreign_key "katello_filter_rules", "katello_filters", :name => "filters_rules_filter_id_fk", :column => 'filter_id'

    add_foreign_key "katello_filters", "katello_content_view_definition_bases", :name => "filters_content_view_definition_id_fk", :column => "content_view_definition_id"

    add_foreign_key "katello_filters_products", "katello_filters", :name => "filters_product_filter_id_fk", :column => 'filter_id'
    add_foreign_key "katello_filters_products", "katello_products", :name => "filters_product_product_id_fk", :column => "product_id"

    add_foreign_key "katello_filters_repositories", "katello_filters", :name => "filters_repositories_filter_id_fk", :column => 'filter_id'
    add_foreign_key "katello_filters_repositories", "katello_repositories", :name => "filters_repositories_repository_id_fk", :column => "repository_id"

    add_foreign_key "katello_help_tips", "users", :name => "help_tips_user_id_fk", :column => 'user_id'

    add_foreign_key "katello_job_tasks", "katello_jobs", :name => "job_tasks_job_id_fk", :column => 'job_id'
    add_foreign_key "katello_job_tasks", "katello_task_statuses", :name => "job_tasks_task_status_id_fk", :column => 'task_status_id'

    add_foreign_key "katello_key_pools", "katello_activation_keys", :name => "key_pools_activation_key_id_fk", :column => 'activation_key_id'
    add_foreign_key "katello_key_pools", "katello_pools", :name => "key_pools_pool_id_fk", :column => 'pool_id'

    add_foreign_key "katello_key_system_groups", "katello_activation_keys", :name => "key_system_groups_activation_key_id_fk", :column => 'activation_key_id'
    add_foreign_key "katello_key_system_groups", "katello_system_groups", :name => "key_system_groups_system_group_id_fk", :column => 'system_group_id'

    add_foreign_key "katello_ldap_group_roles", "katello_roles", :name => "ldap_group_roles_role_id_fk", :column => 'role_id'

    add_foreign_key "katello_marketing_engineering_products", "katello_products", :name => "marketing_engineering_products_engineering_product_id_fk", :column => "engineering_product_id"
    add_foreign_key "katello_marketing_engineering_products", "katello_products", :name => "marketing_engineering_products_marketing_product_id_fk", :column => "marketing_product_id"

    add_foreign_key "katello_node_capabilities", "katello_nodes", :name => "node_capabilities_node_id_fk", :column => 'node_id'

    add_foreign_key "katello_nodes", "katello_systems", :name => "nodes_system_id_fk", :column => 'system_id'

    add_foreign_key "katello_nodes_environments", "katello_environments", :name => "nodes_environments_environment_id_fk", :column => 'environment_id'
    add_foreign_key "katello_nodes_environments", "katello_nodes", :name => "nodes_environments_node_id_fk", :column => 'node_id'

    add_foreign_key "katello_permission_tags", "katello_permissions", :name => "permission_tags_permission_id_fk", :column => 'permission_id'

    add_foreign_key "katello_permissions", "katello_resource_types", :name => "permissions_resource_type_id_fk", :column => 'resource_type_id'
    add_foreign_key "katello_permissions", "katello_roles", :name => "permissions_role_id_fk", :column => 'role_id'

    add_foreign_key "katello_permissions_verbs", "katello_permissions", :name => "permissions_verbs_permission_id_fk", :column => 'permission_id'
    add_foreign_key "katello_permissions_verbs", "katello_verbs", :name => "permissions_verbs_verb_id_fk", :column => 'verb_id'

    add_foreign_key "katello_products", "katello_gpg_keys", :name => "products_gpg_key_id_fk", :column => 'gpg_key_id'
    add_foreign_key "katello_products", "katello_providers", :name => "products_provider_id_fk", :column => 'provider_id'
    add_foreign_key "katello_products", "katello_sync_plans", :name => "products_sync_plan_id_fk", :column => 'sync_plan_id'

    add_foreign_key "katello_providers", "katello_task_statuses", :name => "providers_discovery_task_id_fk", :column => "discovery_task_id"
    add_foreign_key "katello_providers", "katello_task_statuses", :name => "providers_task_status_id_fk", :column => "task_status_id"

    add_foreign_key "katello_repositories", "katello_content_view_versions", :name => "repositories_content_view_version_id_fk", :column => 'content_view_version_id'
    add_foreign_key "katello_repositories", "katello_gpg_keys", :name => "repositories_gpg_key_id_fk", :column => 'gpg_key_id'
    add_foreign_key "katello_repositories", "katello_repositories", :name => "repositories_library_instance_id_fk", :column => "library_instance_id"

    add_foreign_key "katello_roles_users", "katello_roles", :name => "roles_users_role_id_fk", :column => 'role_id'
    add_foreign_key "katello_roles_users", "users", :name => "roles_users_user_id_fk", :column => 'user_id'

    add_foreign_key "katello_search_favorites", "users", :name => "search_favorites_user_id_fk", :column => 'user_id'

    add_foreign_key "katello_search_histories", "users", :name => "search_histories_user_id_fk", :column => 'user_id'

    add_foreign_key "katello_system_activation_keys", "katello_activation_keys", :name => "system_activation_keys_activation_key_id_fk", :column => 'activation_key_id'
    add_foreign_key "katello_system_activation_keys", "katello_systems", :name => "system_activation_keys_system_id_fk", :column => 'system_id'

    add_foreign_key "katello_system_system_groups", "katello_system_groups", :name => "system_system_groups_system_group_id_fk", :column => 'system_group_id'
    add_foreign_key "katello_system_system_groups", "katello_systems", :name => "system_system_groups_system_id_fk", :column => 'system_id'

    add_foreign_key "katello_systems", "katello_content_views", :name => "systems_content_view_id_fk", :column => 'content_view_id'
    add_foreign_key "katello_systems", "katello_environments", :name => "systems_environment_id_fk", :column => 'environment_id'

    add_foreign_key "katello_task_statuses", "users", :name => "task_statuses_user_id_fk", :column => 'user_id'

    add_foreign_key "katello_user_notices", "katello_notices", :name => "user_notices_notice_id_fk", :column => 'notice_id'
    add_foreign_key "katello_user_notices", "users", :name => "user_notices_user_id_fk", :column => 'user_id'

    add_foreign_key "users", "katello_environments", :name => "users_default_environment_id_fk", :column => "default_environment_id"
  end

end
