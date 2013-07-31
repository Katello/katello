class AddForeignKeys < ActiveRecord::Migration

  # TODO remove after FK problems are fixed
  def self.add_foreign_key_deferred(from_table, to_table, options = {})
    add_foreign_key from_table, to_table, options.update(:options => 'INITIALLY DEFERRED')
  end

  def self.up
    add_foreign_key_deferred "katello_activation_keys", "katello_content_views", :name => "activation_keys_content_view_id_fk"
    add_foreign_key_deferred "katello_activation_keys", "katello_environments", :name => "activation_keys_environment_id_fk"
    add_foreign_key_deferred "katello_activation_keys", "katello_organizations", :name => "activation_keys_organization_id_fk"
    # TODO: ENGINIFY: changing all 'katello_users' to 'users', to use core apps user
    add_foreign_key_deferred "katello_activation_keys", "users", :name => "activation_keys_user_id_fk"

    add_foreign_key_deferred "katello_changeset_content_views", "katello_changesets", :name => "changeset_content_views_changeset_id_fk"
    add_foreign_key_deferred "katello_changeset_content_views", "katello_content_views", :name => "changeset_content_views_content_view_id_fk"

    add_foreign_key_deferred "katello_changeset_users", "katello_changesets", :name => "changeset_users_changeset_id_fk"
    add_foreign_key_deferred "katello_changeset_users", "users", :name => "changeset_users_user_id_fk"

    add_foreign_key_deferred "katello_changesets", "katello_environments", :name => "changesets_environment_id_fk"
    add_foreign_key_deferred "katello_changesets", "katello_task_statuses", :name => "changesets_task_status_id_fk"

    add_foreign_key_deferred "katello_component_content_views", "katello_content_view_definition_bases", :name => "component_content_views_content_view_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key_deferred "katello_component_content_views", "katello_content_views", :name => "component_content_views_content_view_id_fk"

    add_foreign_key_deferred "katello_content_view_definition_bases", "katello_content_view_definition_bases", :name => "content_view_definition_bases_source_id_fk", :column => "source_id"
    add_foreign_key_deferred "katello_content_view_definition_bases", "katello_organizations", :name => "content_view_definition_bases_organization_id_fk"

    add_foreign_key_deferred "katello_content_view_definition_products", "katello_content_view_definition_bases", :name => "content_view_definition_products_content_view_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key_deferred "katello_content_view_definition_products", "katello_products", :name => "content_view_definition_products_product_id_fk"

    add_foreign_key_deferred "katello_content_view_definition_repositories", "katello_content_view_definition_bases", :name => "CV_definition_repositories_CV_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key_deferred "katello_content_view_definition_repositories", "katello_repositories", :name => "content_view_definition_repositories_repository_id_fk"

    add_foreign_key_deferred "katello_content_view_environments", "katello_content_views", :name => "content_view_environments_content_view_id_fk"
    add_foreign_key_deferred "katello_content_view_environments", "katello_environments", :name => "content_view_environments_environment_id_fk"

    add_foreign_key_deferred "katello_content_view_version_environments", "katello_content_view_versions", :name => "content_view_version_environments_content_view_version_id_fk"
    add_foreign_key_deferred "katello_content_view_version_environments", "katello_environments", :name => "content_view_version_environments_environment_id_fk"

    add_foreign_key_deferred "katello_content_view_versions", "katello_content_view_definition_bases", :name => "content_view_versions_content_view_definition_archive_id_fk", :column => "definition_archive_id"
    add_foreign_key_deferred "katello_content_view_versions", "katello_content_view_definition_bases", :name => "content_view_versions_definition_archive_id_fk", :column => "definition_archive_id"
    add_foreign_key_deferred "katello_content_view_versions", "katello_content_views", :name => "content_view_versions_content_view_id_fk"

    add_foreign_key_deferred "katello_content_views", "katello_content_view_definition_bases", :name => "content_views_content_view_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key_deferred "katello_content_views", "katello_organizations", :name => "content_views_organization_id_fk"

    add_foreign_key_deferred "katello_distributors", "katello_content_views", :name => "distributors_content_view_id_fk"
    add_foreign_key_deferred "katello_distributors", "katello_environments", :name => "distributors_environment_id_fk"

    add_foreign_key_deferred "katello_environment_priors", "katello_environments", :name => "environment_priors_environment_id_fk"
    add_foreign_key_deferred "katello_environment_priors", "katello_environments", :name => "environment_priors_prior_id_fk", :column => "prior_id"

    add_foreign_key_deferred "katello_environment_system_groups", "katello_environments", :name => "environment_system_groups_environment_id_fk"
    add_foreign_key_deferred "katello_environment_system_groups", "katello_system_groups", :name => "environment_system_groups_system_group_id_fk"

    add_foreign_key_deferred "katello_environments", "katello_organizations", :name => "environments_organization_id_fk"

    add_foreign_key_deferred "katello_filter_rules", "katello_filters", :name => "filters_rules_filter_id_fk"

    add_foreign_key_deferred "katello_filters", "katello_content_view_definition_bases", :name => "filters_content_view_definition_id_fk", :column => "content_view_definition_id"

    add_foreign_key_deferred "katello_filters_products", "katello_filters", :name => "filters_product_filter_id_fk"
    add_foreign_key_deferred "katello_filters_products", "katello_products", :name => "filters_product_product_id_fk"

    add_foreign_key_deferred "katello_filters_repositories", "katello_filters", :name => "filters_repositories_filter_id_fk"
    add_foreign_key_deferred "katello_filters_repositories", "katello_repositories", :name => "filters_repositories_repository_id_fk"

    add_foreign_key_deferred "katello_gpg_keys", "katello_organizations", :name => "gpg_keys_organization_id_fk"

    add_foreign_key_deferred "katello_help_tips", "users", :name => "help_tips_user_id_fk"

    add_foreign_key_deferred "katello_job_tasks", "katello_jobs", :name => "job_tasks_job_id_fk"
    add_foreign_key_deferred "katello_job_tasks", "katello_task_statuses", :name => "job_tasks_task_status_id_fk"

    add_foreign_key_deferred "katello_key_pools", "katello_activation_keys", :name => "key_pools_activation_key_id_fk"
    add_foreign_key_deferred "katello_key_pools", "katello_pools", :name => "key_pools_pool_id_fk"

    add_foreign_key_deferred "katello_key_system_groups", "katello_activation_keys", :name => "key_system_groups_activation_key_id_fk"
    add_foreign_key_deferred "katello_key_system_groups", "katello_system_groups", :name => "key_system_groups_system_group_id_fk"

    add_foreign_key_deferred "katello_ldap_group_roles", "katello_roles", :name => "ldap_group_roles_role_id_fk"

    add_foreign_key_deferred "katello_marketing_engineering_products", "katello_products", :name => "marketing_engineering_products_engineering_product_id_fk", :column => "engineering_product_id"
    add_foreign_key_deferred "katello_marketing_engineering_products", "katello_products", :name => "marketing_engineering_products_marketing_product_id_fk", :column => "marketing_product_id"

    add_foreign_key_deferred "katello_notices", "katello_organizations", :name => "notices_organization_id_fk"

    add_foreign_key_deferred "katello_organizations", "katello_task_statuses", :name => "organizations_apply_info_task_id_fk", :column => "apply_info_task_id"
    add_foreign_key_deferred "katello_organizations", "katello_task_statuses", :name => "organizations_deletion_task_id_fk", :column => "deletion_task_id"

    add_foreign_key_deferred "katello_organizations_users", "katello_organizations", :name => "organizations_users_organization_id_fk"
    add_foreign_key_deferred "katello_organizations_users", "users", :name => "organizations_users_user_id_fk"

    add_foreign_key_deferred "katello_permission_tags", "katello_permissions", :name => "permission_tags_permission_id_fk"

    add_foreign_key_deferred "katello_permissions", "katello_organizations", :name => "permissions_organization_id_fk"
    add_foreign_key_deferred "katello_permissions", "katello_resource_types", :name => "permissions_resource_type_id_fk"
    add_foreign_key_deferred "katello_permissions", "katello_roles", :name => "permissions_role_id_fk"

    add_foreign_key_deferred "katello_permissions_verbs", "katello_permissions", :name => "permissions_verbs_permission_id_fk"
    add_foreign_key_deferred "katello_permissions_verbs", "katello_verbs", :name => "permissions_verbs_verb_id_fk"

    add_foreign_key_deferred "katello_products", "katello_gpg_keys", :name => "products_gpg_key_id_fk"
    add_foreign_key_deferred "katello_products", "katello_providers", :name => "products_provider_id_fk"
    add_foreign_key_deferred "katello_products", "katello_sync_plans", :name => "products_sync_plan_id_fk"

    add_foreign_key_deferred "katello_providers", "katello_organizations", :name => "providers_organization_id_fk"
    add_foreign_key_deferred "katello_providers", "katello_task_statuses", :name => "providers_discovery_task_id_fk", :column => "discovery_task_id"
    add_foreign_key_deferred "katello_providers", "katello_task_statuses", :name => "providers_task_status_id_fk"

    add_foreign_key_deferred "katello_repositories", "katello_content_view_versions", :name => "repositories_content_view_version_id_fk"
    add_foreign_key_deferred "katello_repositories", "katello_gpg_keys", :name => "repositories_gpg_key_id_fk"
    add_foreign_key_deferred "katello_repositories", "katello_repositories", :name => "repositories_library_instance_id_fk", :column => "library_instance_id"

    add_foreign_key_deferred "katello_roles_users", "katello_roles", :name => "roles_users_role_id_fk"
    add_foreign_key_deferred "katello_roles_users", "users", :name => "roles_users_user_id_fk"

    add_foreign_key_deferred "katello_search_favorites", "users", :name => "search_favorites_user_id_fk"

    add_foreign_key_deferred "katello_search_histories", "users", :name => "search_histories_user_id_fk"

    add_foreign_key_deferred "katello_sync_plans", "katello_organizations", :name => "sync_plans_organization_id_fk"

    add_foreign_key_deferred "katello_system_activation_keys", "katello_activation_keys", :name => "system_activation_keys_activation_key_id_fk"
    add_foreign_key_deferred "katello_system_activation_keys", "katello_systems", :name => "system_activation_keys_system_id_fk"

    add_foreign_key_deferred "katello_system_groups", "katello_organizations", :name => "system_groups_organization_id_fk"

    add_foreign_key_deferred "katello_system_system_groups", "katello_system_groups", :name => "system_system_groups_system_group_id_fk"
    add_foreign_key_deferred "katello_system_system_groups", "katello_systems", :name => "system_system_groups_system_id_fk"

    add_foreign_key_deferred "katello_systems", "katello_content_views", :name => "systems_content_view_id_fk"
    add_foreign_key_deferred "katello_systems", "katello_environments", :name => "systems_environment_id_fk"

    add_foreign_key_deferred "katello_task_statuses", "katello_organizations", :name => "task_statuses_organization_id_fk"
    add_foreign_key_deferred "katello_task_statuses", "users", :name => "task_statuses_user_id_fk"

    add_foreign_key_deferred "katello_user_notices", "katello_notices", :name => "user_notices_notice_id_fk"
    add_foreign_key_deferred "katello_user_notices", "users", :name => "user_notices_user_id_fk"

    add_foreign_key_deferred "users", "katello_environments", :name => "users_default_environment_id_fk", :column => "default_environment_id"
  end


  def self.down
    remove_foreign_key "katello_activation_keys", :name => "activation_keys_content_view_id_fk"
    remove_foreign_key "katello_activation_keys", :name => "activation_keys_environment_id_fk"
    remove_foreign_key "katello_activation_keys", :name => "activation_keys_organization_id_fk"
    remove_foreign_key "katello_activation_keys", :name => "activation_keys_user_id_fk"

    remove_foreign_key "katello_changeset_content_views", :name => "changeset_content_views_changeset_id_fk"
    remove_foreign_key "katello_changeset_content_views", :name => "changeset_content_views_content_view_id_fk"

    remove_foreign_key "katello_changeset_users", :name => "changeset_users_changeset_id_fk"
    remove_foreign_key "katello_changeset_users", :name => "changeset_users_user_id_fk"

    remove_foreign_key "katello_changesets", :name => "changesets_environment_id_fk"
    remove_foreign_key "katello_changesets", :name => "changesets_task_status_id_fk"

    remove_foreign_key "katello_component_content_views", :name => "component_content_views_content_view_definition_id_fk", :column => "content_view_definition_id"
    remove_foreign_key "katello_component_content_views", :name => "component_content_views_content_view_id_fk"

    remove_foreign_key "katello_content_view_definition_bases", :name => "content_view_definition_bases_source_id_fk", :column => "source_id"
    remove_foreign_key "katello_content_view_definition_bases", :name => "content_view_definition_bases_organization_id_fk"

    remove_foreign_key "katello_content_view_definition_products", :name => "content_view_definition_products_content_view_definition_id_fk", :column => "content_view_definition_id"
    remove_foreign_key "katello_content_view_definition_products", :name => "content_view_definition_products_product_id_fk"

    remove_foreign_key "katello_content_view_definition_repositories", :name => "CV_definition_repositories_CV_definition_id_fk", :column => "content_view_definition_id"
    remove_foreign_key "katello_content_view_definition_repositories", :name => "content_view_definition_repositories_repository_id_fk"
remove_foreign_key
    remove_foreign_key "katello_content_view_environments", :name => "content_view_environments_content_view_id_fk"
    remove_foreign_key "katello_content_view_environments", :name => "content_view_environments_environment_id_fk"

    remove_foreign_key "katello_content_view_version_environments", :name => "content_view_version_environments_content_view_version_id_fk"
    remove_foreign_key "katello_content_view_version_environments", :name => "content_view_version_environments_environment_id_fk"

    remove_foreign_key "katello_content_view_versions", :name => "content_view_versions_content_view_definition_archive_id_fk", :column => "definition_archive_id"
    remove_foreign_key "katello_content_view_versions", :name => "content_view_versions_definition_archive_id_fk", :column => "definition_archive_id"
    remove_foreign_key "katello_content_view_versions", :name => "content_view_versions_content_view_id_fk"

    remove_foreign_key "katello_content_views", :name => "content_views_content_view_definition_id_fk", :column => "content_view_definition_id"
    remove_foreign_key "katello_content_views", :name => "content_views_organization_id_fk"

    remove_foreign_key "katello_distributors", :name => "distributors_content_view_id_fk"
    remove_foreign_key "katello_distributors", :name => "distributors_environment_id_fk"

    remove_foreign_key "katello_environment_priors", :name => "environment_priors_environment_id_fk"
    remove_foreign_key "katello_environment_priors", :name => "environment_priors_prior_id_fk", :column => "prior_id"

    remove_foreign_key "katello_environment_system_groups", :name => "environment_system_groups_environment_id_fk"
    remove_foreign_key "katello_environment_system_groups", :name => "environment_system_groups_system_group_id_fk"

    remove_foreign_key "katello_environments", :name => "environments_organization_id_fk"

    remove_foreign_key "katello_filter_rules", :name => "filters_rules_filter_id_fk"

    remove_foreign_key "katello_filters", :name => "filters_content_view_definition_id_fk", :column => "content_view_definition_id"

    remove_foreign_key "katello_filters_products", :name => "filters_product_filter_id_fk"
    remove_foreign_key "katello_filters_products", :name => "filters_product_product_id_fk"

    remove_foreign_key "katello_filters_repositories", :name => "filters_repositories_filter_id_fk"
    remove_foreign_key "katello_filters_repositories", :name => "filters_repositories_repository_id_fk"

    remove_foreign_key "katello_gpg_keys", :name => "gpg_keys_organization_id_fk"

    remove_foreign_key "katello_help_tips", :name => "help_tips_user_id_fk"

    remove_foreign_key "katello_job_tasks", :name => "job_tasks_job_id_fk"
    remove_foreign_key "katello_job_tasks", :name => "job_tasks_task_status_id_fk"

    remove_foreign_key "katello_key_pools", :name => "key_pools_activation_key_id_fk"
    remove_foreign_key "katello_key_pools", :name => "key_pools_pool_id_fk"

    remove_foreign_key "katello_key_system_groups", :name => "key_system_groups_activation_key_id_fk"
    remove_foreign_key "katello_key_system_groups", :name => "key_system_groups_system_group_id_fk"

    remove_foreign_key "katello_ldap_group_roles", :name => "ldap_group_roles_role_id_fk"

    remove_foreign_key "katello_marketing_engineering_products", :name => "marketing_engineering_products_engineering_product_id_fk", :column => "engineering_product_id"
    remove_foreign_key "katello_marketing_engineering_products", :name => "marketing_engineering_products_marketing_product_id_fk", :column => "marketing_product_id"

    remove_foreign_key "katello_notices", :name => "notices_organization_id_fk"

    remove_foreign_key "katello_organizations", :name => "organizations_apply_info_task_id_fk", :column => "apply_info_task_id"
    remove_foreign_key "katello_organizations", :name => "organizations_deletion_task_id_fk", :column => "deletion_task_id"

    remove_foreign_key "katello_organizations_users", :name => "organizations_users_organization_id_fk"
    remove_foreign_key "katello_organizations_users", :name => "organizations_users_user_id_fk"

    remove_foreign_key "katello_permission_tags", :name => "permission_tags_permission_id_fk"

    remove_foreign_key "katello_permissions", :name => "permissions_organization_id_fk"
    remove_foreign_key "katello_permissions", :name => "permissions_resource_type_id_fk"
    remove_foreign_key "katello_permissions", :name => "permissions_role_id_fk"

    remove_foreign_key "katello_permissions_verbs", :name => "permissions_verbs_permission_id_fk"
    remove_foreign_key "katello_permissions_verbs", :name => "permissions_verbs_verb_id_fk"

    remove_foreign_key "katello_products", :name => "products_gpg_key_id_fk"
    remove_foreign_key "katello_products", :name => "products_provider_id_fk"
    remove_foreign_key "katello_products", :name => "products_sync_plan_id_fk"

    remove_foreign_key "katello_providers", :name => "providers_organization_id_fk"
    remove_foreign_key "katello_providers", :name => "providers_discovery_task_id_fk", :column => "discovery_task_id"
    remove_foreign_key "katello_providers", :name => "providers_task_status_id_fk"

    remove_foreign_key "katello_repositories", :name => "repositories_content_view_version_id_fk"
    remove_foreign_key "katello_repositories", :name => "repositories_gpg_key_id_fk"
    remove_foreign_key "katello_repositories", :name => "repositories_library_instance_id_fk", :column => "library_instance_id"

    remove_foreign_key "katello_roles_users", :name => "roles_users_role_id_fk"
    remove_foreign_key "katello_roles_users", :name => "roles_users_user_id_fk"

    remove_foreign_key "katello_search_favorites", :name => "search_favorites_user_id_fk"

    remove_foreign_key "katello_search_histories", :name => "search_histories_user_id_fk"

    remove_foreign_key "katello_sync_plans", :name => "sync_plans_organization_id_fk"

    remove_foreign_key "katello_system_activation_keys", :name => "system_activation_keys_activation_key_id_fk"
    remove_foreign_key "katello_system_activation_keys", :name => "system_activation_keys_system_id_fk"

    remove_foreign_key "katello_system_groups", :name => "system_groups_organization_id_fk"

    remove_foreign_key "katello_system_system_groups", :name => "system_system_groups_system_group_id_fk"
    remove_foreign_key "katello_system_system_groups", :name => "system_system_groups_system_id_fk"

    remove_foreign_key "katello_systems", :name => "systems_content_view_id_fk"
    remove_foreign_key "katello_systems", :name => "systems_environment_id_fk"

    remove_foreign_key "katello_task_statuses", :name => "task_statuses_organization_id_fk"
    remove_foreign_key "katello_task_statuses", :name => "task_statuses_user_id_fk"

    remove_foreign_key "katello_user_notices", :name => "user_notices_notice_id_fk"
    remove_foreign_key "katello_user_notices", :name => "user_notices_user_id_fk"

    remove_foreign_key "users", :name => "users_default_environment_id_fk", :column => "default_environment_id"
  end

end

