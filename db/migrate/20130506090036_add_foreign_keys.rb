class AddForeignKeys < ActiveRecord::Migration

  # TODO remove after FK problems are fixed
  def self.add_foreign_key_deferred(from_table, to_table, options = {})
    add_foreign_key from_table, to_table, options.update(:options => 'INITIALLY DEFERRED')
  end

  def self.up
    add_foreign_key_deferred 'activation_keys', 'content_views',
                             :name => 'activation_keys_content_view_id_fk'
    add_foreign_key_deferred 'activation_keys', 'environments',
                             :name => 'activation_keys_environment_id_fk'
    add_foreign_key_deferred 'activation_keys', 'organizations',
                             :name => 'activation_keys_organization_id_fk'
    add_foreign_key_deferred 'activation_keys', 'users',
                             :name => 'activation_keys_user_id_fk'
    add_foreign_key_deferred 'changeset_content_views', 'changesets',
                             :name => 'changeset_content_views_changeset_id_fk'
    add_foreign_key_deferred 'changeset_content_views', 'content_views',
                             :name => 'changeset_content_views_content_view_id_fk'
    add_foreign_key_deferred 'changeset_dependencies', 'changesets',
                             :name => 'changeset_dependencies_changeset_id_fk'
    add_foreign_key_deferred 'changeset_dependencies', 'products',
                             :name => 'changeset_dependencies_product_id_fk'
    add_foreign_key_deferred 'changeset_distributions', 'changesets',
                             :name => 'changeset_distributions_changeset_id_fk'
    add_foreign_key_deferred 'changeset_distributions', 'products',
                             :name => 'changeset_distributions_product_id_fk'
    add_foreign_key_deferred 'changeset_errata', 'changesets',
                             :name => 'changeset_errata_changeset_id_fk'
    add_foreign_key_deferred 'changeset_errata', 'products',
                             :name => 'changeset_errata_product_id_fk'
    add_foreign_key_deferred 'changeset_packages', 'changesets',
                             :name => 'changeset_packages_changeset_id_fk'
    add_foreign_key_deferred 'changeset_packages', 'products',
                             :name => 'changeset_packages_product_id_fk'
    add_foreign_key_deferred 'changeset_users', 'changesets',
                             :name => 'changeset_users_changeset_id_fk'
    add_foreign_key_deferred 'changeset_users', 'users',
                             :name => 'changeset_users_user_id_fk'
    add_foreign_key_deferred 'changesets', 'environments',
                             :name => 'changesets_environment_id_fk'
    add_foreign_key_deferred 'changesets_products', 'changesets',
                             :name => 'changesets_products_changeset_id_fk'
    add_foreign_key_deferred 'changesets_products', 'products',
                             :name => 'changesets_products_product_id_fk'
    add_foreign_key_deferred 'changesets_repositories', 'changesets',
                             :name => 'changesets_repositories_changeset_id_fk'
    add_foreign_key_deferred 'changesets_repositories', 'repositories',
                             :name => 'changesets_repositories_repository_id_fk'
    add_foreign_key_deferred 'changesets', 'task_statuses',
                             :name => 'changesets_task_status_id_fk'
    add_foreign_key_deferred 'component_content_views', 'content_view_definition_bases',
                             :name   => 'component_content_views_content_view_definition_id_fk',
                             :column => 'content_view_definition_id'
    add_foreign_key_deferred 'component_content_views', 'content_views',
                             :name => 'component_content_views_content_view_id_fk'
    add_foreign_key_deferred 'content_view_definition_bases', 'organizations',
                             :name => 'content_view_definition_bases_organization_id_fk'
    add_foreign_key_deferred 'content_view_definition_bases', 'content_view_definition_bases',
                             :name   => 'content_view_definition_bases_source_id_fk',
                             :column => 'source_id'
    add_foreign_key_deferred 'content_view_definition_products', 'content_view_definition_bases',
                             :name   => 'content_view_definition_products_content_view_definition_id_fk',
                             :column => 'content_view_definition_id'
    add_foreign_key_deferred 'content_view_definition_products', 'products',
                             :name => 'content_view_definition_products_product_id_fk'
    add_foreign_key_deferred 'content_view_definition_repositories', 'content_view_definition_bases',
                             # changed to fit under 63 chars
                             :name   => 'CV_definition_repositories_CV_definition_id_fk',
                             :column => 'content_view_definition_id'
    add_foreign_key_deferred 'content_view_definition_repositories', 'repositories',
                             :name => 'content_view_definition_repositories_repository_id_fk'
    add_foreign_key_deferred 'content_view_environments', 'content_views',
                             :name => 'content_view_environments_content_view_id_fk'
    add_foreign_key_deferred 'content_view_environments', 'environments',
                             :name => 'content_view_environments_environment_id_fk'
    add_foreign_key_deferred 'content_view_version_environments', 'content_view_versions',
                             :name => 'content_view_version_environments_content_view_version_id_fk'
    add_foreign_key_deferred 'content_view_version_environments', 'environments',
                             :name => 'content_view_version_environments_environment_id_fk'
    add_foreign_key_deferred 'content_view_versions', 'content_view_definition_bases',
                             :name   => 'content_view_versions_content_view_definition_archive_id_fk',
                             #:column => 'content_view_definition_archive_id'
                             :column => 'definition_archive_id'
    add_foreign_key_deferred 'content_view_versions', 'content_views',
                             :name => 'content_view_versions_content_view_id_fk'
    add_foreign_key_deferred 'content_view_versions', 'content_view_definition_bases',
                             :name   => 'content_view_versions_definition_archive_id_fk',
                             :column => 'definition_archive_id'
    add_foreign_key_deferred 'content_views', 'content_view_definition_bases',
                             :name   => 'content_views_content_view_definition_id_fk',
                             :column => 'content_view_definition_id'
    #add_foreign_key_deferred 'content_views', 'environments',
    #                         :name   => 'content_views_environment_default_id_fk',
    #                         :column => 'environment_default_id'
    add_foreign_key_deferred 'content_views', 'organizations',
                             :name => 'content_views_organization_id_fk'
    add_foreign_key_deferred 'distributors', 'content_views',
                             :name => 'distributors_content_view_id_fk',
                             :column => 'content_view_id'
    add_foreign_key_deferred 'distributors', 'environments',
                             :name => 'distributors_environment_id_fk'
    add_foreign_key_deferred 'environment_priors', 'environments',
                             :name => 'environment_priors_environment_id_fk'
    add_foreign_key_deferred 'environment_priors', 'environments',
                             :name   => 'environment_priors_prior_id_fk',
                             :column => 'prior_id'
    add_foreign_key_deferred 'environment_products', 'environments',
                             :name => 'environment_products_environment_id_fk'
    add_foreign_key_deferred 'environment_products', 'products',
                             :name => 'environment_products_product_id_fk'
    add_foreign_key_deferred 'environment_system_groups', 'environments',
                             :name => 'environment_system_groups_environment_id_fk'
    add_foreign_key_deferred 'environment_system_groups', 'system_groups',
                             :name => 'environment_system_groups_system_group_id_fk'
    add_foreign_key_deferred 'environments', 'organizations',
                             :name => 'environments_organization_id_fk'
    add_foreign_key_deferred 'gpg_keys', 'organizations',
                             :name => 'gpg_keys_organization_id_fk'
    add_foreign_key_deferred 'help_tips', 'users',
                             :name => 'help_tips_user_id_fk'
    add_foreign_key_deferred 'job_tasks', 'jobs',
                             :name => 'job_tasks_job_id_fk'
    add_foreign_key_deferred 'job_tasks', 'task_statuses',
                             :name => 'job_tasks_task_status_id_fk'
    add_foreign_key_deferred 'key_pools', 'activation_keys',
                             :name => 'key_pools_activation_key_id_fk'
    add_foreign_key_deferred 'key_pools', 'pools',
                             :name => 'key_pools_pool_id_fk'
    add_foreign_key_deferred 'key_system_groups', 'activation_keys',
                             :name => 'key_system_groups_activation_key_id_fk'
    add_foreign_key_deferred 'key_system_groups', 'system_groups',
                             :name => 'key_system_groups_system_group_id_fk'
    add_foreign_key_deferred 'ldap_group_roles', 'roles',
                             :name => 'ldap_group_roles_role_id_fk'
    add_foreign_key_deferred 'marketing_engineering_products', 'products',
                             :name   => 'marketing_engineering_products_engineering_product_id_fk',
                             :column => 'engineering_product_id'
    add_foreign_key_deferred 'marketing_engineering_products', 'products',
                             :name   => 'marketing_engineering_products_marketing_product_id_fk',
                             :column => 'marketing_product_id'
    add_foreign_key_deferred 'notices', 'organizations',
                             :name => 'notices_organization_id_fk'
    add_foreign_key_deferred 'permission_tags', 'permissions',
                             :name => 'permission_tags_permission_id_fk'
    add_foreign_key_deferred 'permissions', 'organizations',
                             :name => 'permissions_organization_id_fk'
    add_foreign_key_deferred 'permissions', 'resource_types',
                             :name => 'permissions_resource_type_id_fk'
    add_foreign_key_deferred 'permissions', 'roles',
                             :name => 'permissions_role_id_fk'
    add_foreign_key_deferred 'permissions_verbs', 'permissions',
                             :name => 'permissions_verbs_permission_id_fk'
    add_foreign_key_deferred 'permissions_verbs', 'verbs',
                             :name => 'permissions_verbs_verb_id_fk'
    add_foreign_key_deferred 'products', 'gpg_keys',
                             :name => 'products_gpg_key_id_fk'
    add_foreign_key_deferred 'products', 'providers',
                             :name => 'products_provider_id_fk'
    add_foreign_key_deferred 'products', 'sync_plans',
                             :name => 'products_sync_plan_id_fk'
    add_foreign_key_deferred 'providers', 'task_statuses',
                             :name   => 'providers_discovery_task_id_fk',
                             :column => 'discovery_task_id'
    add_foreign_key_deferred 'providers', 'organizations',
                             :name => 'providers_organization_id_fk'
    add_foreign_key_deferred 'providers', 'task_statuses',
                             :name => 'providers_task_status_id_fk'
    add_foreign_key_deferred 'repositories', 'content_view_versions',
                             :name => 'repositories_content_view_version_id_fk'
    add_foreign_key_deferred 'repositories', 'environment_products',
                             :name => 'repositories_environment_product_id_fk'
    add_foreign_key_deferred 'repositories', 'gpg_keys',
                             :name => 'repositories_gpg_key_id_fk'
    add_foreign_key_deferred 'repositories', 'repositories',
                             :name   => 'repositories_library_instance_id_fk',
                             :column => 'library_instance_id'
    #add_foreign_key_deferred 'resource_types', 'permissions',
    #                         :name => 'resource_types_permission_id_fk'
    add_foreign_key_deferred 'roles_users', 'roles',
                             :name => 'roles_users_role_id_fk'
    add_foreign_key_deferred 'roles_users', 'users',
                             :name => 'roles_users_user_id_fk'
    add_foreign_key_deferred 'search_favorites', 'users',
                             :name => 'search_favorites_user_id_fk'
    add_foreign_key_deferred 'search_histories', 'users',
                             :name => 'search_histories_user_id_fk'
    add_foreign_key_deferred 'sync_plans', 'organizations',
                             :name => 'sync_plans_organization_id_fk'
    add_foreign_key_deferred 'system_activation_keys', 'activation_keys',
                             :name => 'system_activation_keys_activation_key_id_fk'
    add_foreign_key_deferred 'system_activation_keys', 'systems',
                             :name => 'system_activation_keys_system_id_fk'
    add_foreign_key_deferred 'system_groups', 'organizations',
                             :name => 'system_groups_organization_id_fk'
    add_foreign_key_deferred 'system_system_groups', 'system_groups',
                             :name => 'system_system_groups_system_group_id_fk'
    add_foreign_key_deferred 'system_system_groups', 'systems',
                             :name => 'system_system_groups_system_id_fk'
    add_foreign_key_deferred 'systems', 'content_views',
                             :name => 'systems_content_view_id_fk'
    add_foreign_key_deferred 'systems', 'environments',
                             :name => 'systems_environment_id_fk'
    add_foreign_key_deferred 'task_statuses', 'organizations',
                             :name => 'task_statuses_organization_id_fk'
    add_foreign_key_deferred 'task_statuses', 'users',
                             :name => 'task_statuses_user_id_fk'
    add_foreign_key_deferred 'user_notices', 'notices',
                             :name => 'user_notices_notice_id_fk'
    add_foreign_key_deferred 'user_notices', 'users',
                             :name => 'user_notices_user_id_fk'
    add_foreign_key_deferred 'users', 'environments',
                             :name   => 'users_default_environment_id_fk',
                             :column => 'default_environment_id'
    add_foreign_key_deferred 'organizations_users', 'users',
                             :name => 'organizations_users_user_id_fk',
                             :column => 'user_id'
    add_foreign_key_deferred 'organizations_users', 'organizations',
                             :name => 'organizations_users_organization_id_fk',
                             :column => 'organization_id'
    add_foreign_key_deferred 'filters_repositories', 'filters',
                             :name => 'filters_repositories_filter_id_fk',
                             :column => 'filter_id'
    add_foreign_key_deferred 'filters_repositories', 'repositories',
                             :name => 'filters_repositories_repository_id_fk',
                             :column => 'repository_id'
    add_foreign_key_deferred 'filters_products', 'filters',
                             :name => 'filters_product_filter_id_fk',
                             :column => 'filter_id'
    add_foreign_key_deferred 'filters_products', 'products',
                             :name => 'filters_product_product_id_fk',
                             :column => 'product_id'
    add_foreign_key_deferred 'filters', 'content_view_definition_bases',
                             :name => 'filters_content_view_definition_id_fk',
                             :column => 'content_view_definition_id'
    add_foreign_key_deferred 'filter_rules', 'filters',
                             :name => 'filters_rules_filter_id_fk',
                             :column => 'filter_id'
    add_foreign_key_deferred 'organizations', 'task_statuses',
                             :name => 'organizations_deletion_task_id_fk',
                             :column => 'deletion_task_id'
    add_foreign_key_deferred 'organizations', 'task_statuses',
                             :name => 'organizations_apply_info_task_id_fk',
                             :column => 'apply_info_task_id'
  end

  def self.down
    remove_foreign_key 'activation_keys',
                       :name => 'activation_keys_content_view_id_fk'
    remove_foreign_key 'activation_keys',
                       :name => 'activation_keys_environment_id_fk'
    remove_foreign_key 'activation_keys',
                       :name => 'activation_keys_organization_id_fk'
    remove_foreign_key 'activation_keys',
                       :name => 'activation_keys_user_id_fk'
    remove_foreign_key 'changeset_content_views',
                       :name => 'changeset_content_views_changeset_id_fk'
    remove_foreign_key 'changeset_content_views',
                       :name => 'changeset_content_views_content_view_id_fk'
    remove_foreign_key 'changeset_dependencies',
                       :name => 'changeset_dependencies_changeset_id_fk'
    remove_foreign_key 'changeset_dependencies',
                       :name => 'changeset_dependencies_product_id_fk'
    remove_foreign_key 'changeset_distributions',
                       :name => 'changeset_distributions_changeset_id_fk'
    remove_foreign_key 'changeset_distributions',
                       :name => 'changeset_distributions_product_id_fk'
    remove_foreign_key 'changeset_errata',
                       :name => 'changeset_errata_changeset_id_fk'
    remove_foreign_key 'changeset_errata',
                       :name => 'changeset_errata_product_id_fk'
    remove_foreign_key 'changeset_packages',
                       :name => 'changeset_packages_changeset_id_fk'
    remove_foreign_key 'changeset_packages',
                       :name => 'changeset_packages_product_id_fk'
    remove_foreign_key 'changeset_users',
                       :name => 'changeset_users_changeset_id_fk'
    remove_foreign_key 'changeset_users',
                       :name => 'changeset_users_user_id_fk'
    remove_foreign_key 'changesets',
                       :name => 'changesets_environment_id_fk'
    remove_foreign_key 'changesets_products',
                       :name => 'changesets_products_changeset_id_fk'
    remove_foreign_key 'changesets_products',
                       :name => 'changesets_products_product_id_fk'
    remove_foreign_key 'changesets_repositories',
                       :name => 'changesets_repositories_changeset_id_fk'
    remove_foreign_key 'changesets_repositories',
                       :name => 'changesets_repositories_repository_id_fk'
    remove_foreign_key 'changesets',
                       :name => 'changesets_task_status_id_fk'
    remove_foreign_key 'component_content_views',
                       :name => 'component_content_views_content_view_definition_id_fk'
    remove_foreign_key 'component_content_views',
                       :name => 'component_content_views_content_view_id_fk'
    remove_foreign_key 'content_view_definition_bases',
                       :name => 'content_view_definition_bases_organization_id_fk'
    remove_foreign_key 'content_view_definition_bases',
                       :name => 'content_view_definition_bases_source_id_fk'
    remove_foreign_key 'content_view_definition_products',
                       :name => 'content_view_definition_products_content_view_definition_id_fk'
    remove_foreign_key 'content_view_definition_products',
                       :name => 'content_view_definition_products_product_id_fk'
    remove_foreign_key 'content_view_definition_repositories',
                       # changed to fit under 63 chars
                       :name => 'CV_definition_repositories_CV_definition_id_fk'
    remove_foreign_key 'content_view_definition_repositories',
                       :name => 'content_view_definition_repositories_repository_id_fk'
    remove_foreign_key 'content_view_environments',
                       :name => 'content_view_environments_content_view_id_fk'
    remove_foreign_key 'content_view_environments',
                       :name => 'content_view_environments_environment_id_fk'
    remove_foreign_key 'content_view_version_environments',
                       :name => 'content_view_version_environments_content_view_version_id_fk'
    remove_foreign_key 'content_view_version_environments',
                       :name => 'content_view_version_environments_environment_id_fk'
    remove_foreign_key 'content_view_versions',
                       :name => 'content_view_versions_content_view_definition_archive_id_fk'
    remove_foreign_key 'content_view_versions',
                       :name => 'content_view_versions_content_view_id_fk'
    remove_foreign_key 'content_view_versions',
                       :name => 'content_view_versions_definition_archive_id_fk'
    remove_foreign_key 'content_views',
                       :name => 'content_views_content_view_definition_id_fk'
    #remove_foreign_key 'content_views',
    #                   :name => 'content_views_environment_default_id_fk'
    remove_foreign_key 'content_views',
                       :name => 'content_views_organization_id_fk'
    #remove_foreign_key 'distributors',
    #                   :name => 'distributors_content_view_id_fk'
    remove_foreign_key 'distributors',
                       :name => 'distributors_environment_id_fk'
    remove_foreign_key 'environment_priors',
                       :name => 'environment_priors_environment_id_fk'
    remove_foreign_key 'environment_priors',
                       :name => 'environment_priors_prior_id_fk'
    remove_foreign_key 'environment_products',
                       :name => 'environment_products_environment_id_fk'
    remove_foreign_key 'environment_products',
                       :name => 'environment_products_product_id_fk'
    remove_foreign_key 'environment_system_groups',
                       :name => 'environment_system_groups_environment_id_fk'
    remove_foreign_key 'environment_system_groups',
                       :name => 'environment_system_groups_system_group_id_fk'
    remove_foreign_key 'environments',
                       :name => 'environments_organization_id_fk'
    remove_foreign_key 'gpg_keys',
                       :name => 'gpg_keys_organization_id_fk'
    remove_foreign_key 'help_tips',
                       :name => 'help_tips_user_id_fk'
    remove_foreign_key 'job_tasks',
                       :name => 'job_tasks_job_id_fk'
    remove_foreign_key 'job_tasks',
                       :name => 'job_tasks_task_status_id_fk'
    remove_foreign_key 'key_pools',
                       :name => 'key_pools_activation_key_id_fk'
    remove_foreign_key 'key_pools',
                       :name => 'key_pools_pool_id_fk'
    remove_foreign_key 'key_system_groups',
                       :name => 'key_system_groups_activation_key_id_fk'
    remove_foreign_key 'key_system_groups',
                       :name => 'key_system_groups_system_group_id_fk'
    remove_foreign_key 'ldap_group_roles',
                       :name => 'ldap_group_roles_role_id_fk'
    remove_foreign_key 'marketing_engineering_products',
                       :name => 'marketing_engineering_products_engineering_product_id_fk'
    remove_foreign_key 'marketing_engineering_products',
                       :name => 'marketing_engineering_products_marketing_product_id_fk'
    remove_foreign_key 'notices',
                       :name => 'notices_organization_id_fk'
    remove_foreign_key 'permission_tags',
                       :name => 'permission_tags_permission_id_fk'
    remove_foreign_key 'permissions',
                       :name => 'permissions_organization_id_fk'
    remove_foreign_key 'permissions',
                       :name => 'permissions_resource_type_id_fk'
    remove_foreign_key 'permissions',
                       :name => 'permissions_role_id_fk'
    remove_foreign_key 'permissions_verbs',
                       :name => 'permissions_verbs_permission_id_fk'
    remove_foreign_key 'permissions_verbs',
                       :name => 'permissions_verbs_verb_id_fk'
    remove_foreign_key 'products',
                       :name => 'products_gpg_key_id_fk'
    remove_foreign_key 'products',
                       :name => 'products_provider_id_fk'
    remove_foreign_key 'products',
                       :name => 'products_sync_plan_id_fk'
    remove_foreign_key 'providers',
                       :name => 'providers_discovery_task_id_fk'
    remove_foreign_key 'providers',
                       :name => 'providers_organization_id_fk'
    remove_foreign_key 'providers',
                       :name => 'providers_task_status_id_fk'
    remove_foreign_key 'repositories',
                       :name => 'repositories_content_view_version_id_fk'
    remove_foreign_key 'repositories',
                       :name => 'repositories_environment_product_id_fk'
    remove_foreign_key 'repositories',
                       :name => 'repositories_gpg_key_id_fk'
    remove_foreign_key 'repositories',
                       :name => 'repositories_library_instance_id_fk'
    #remove_foreign_key 'resource_types',
    #                   :name => 'resource_types_permission_id_fk'
    remove_foreign_key 'roles_users',
                       :name => 'roles_users_role_id_fk'
    remove_foreign_key 'roles_users',
                       :name => 'roles_users_user_id_fk'
    remove_foreign_key 'search_favorites',
                       :name => 'search_favorites_user_id_fk'
    remove_foreign_key 'search_histories',
                       :name => 'search_histories_user_id_fk'
    remove_foreign_key 'sync_plans',
                       :name => 'sync_plans_organization_id_fk'
    remove_foreign_key 'system_activation_keys',
                       :name => 'system_activation_keys_activation_key_id_fk'
    remove_foreign_key 'system_activation_keys',
                       :name => 'system_activation_keys_system_id_fk'
    remove_foreign_key 'system_groups',
                       :name => 'system_groups_organization_id_fk'
    remove_foreign_key 'system_system_groups',
                       :name => 'system_system_groups_system_group_id_fk'
    remove_foreign_key 'system_system_groups',
                       :name => 'system_system_groups_system_id_fk'
    remove_foreign_key 'systems',
                       :name => 'systems_content_view_id_fk'
    remove_foreign_key 'systems',
                       :name => 'systems_environment_id_fk'
    remove_foreign_key 'task_statuses',
                       :name => 'task_statuses_organization_id_fk'
    remove_foreign_key 'task_statuses',
                       :name => 'task_statuses_user_id_fk'
    remove_foreign_key 'user_notices',
                       :name => 'user_notices_notice_id_fk'
    remove_foreign_key 'user_notices',
                       :name => 'user_notices_user_id_fk'
    remove_foreign_key 'users',
                       :name => 'users_default_environment_id_fk'
    remove_foreign_key 'organizations_users',
                       :name => 'organizations_users_user_id_fk'
    remove_foreign_key 'organizations_users',
                       :name => 'organizations_users_organization_id_fk'
    remove_foreign_key 'filters_repositories',
                       :name => 'filters_repositories_filter_id_fk'
    remove_foreign_key 'filters_repositories',
                       :name => 'filters_repositories_repository_id_fk'
    remove_foreign_key 'filters_products',
                       :name => 'filters_product_filter_id_fk'
    remove_foreign_key 'filters_products',
                       :name => 'filters_product_product_id_fk'
    remove_foreign_key 'filters',
                       :name => 'filters_content_view_definition_id_fk'
    remove_foreign_key 'filter_rules',
                       :name => 'filters_rules_filter_id_fk'
    remove_foreign_key 'organizations',
                       :name => 'organizations_deletion_task_id_fk'
    remove_foreign_key 'organizations',
                       :name => 'organizations_apply_info_task_id_fk'
  end
end
