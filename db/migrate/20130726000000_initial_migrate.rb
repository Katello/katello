class InitialMigrate < ActiveRecord::Migration

  def self.up

    create_table "katello_activation_keys", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.integer  "organization_id",                 :null => false
      t.integer  "environment_id",                  :null => false
      t.datetime "created_at",                      :null => false
      t.datetime "updated_at",                      :null => false
      t.integer  "user_id"
      t.integer  "usage_limit",     :default => -1
      t.integer  "content_view_id"
    end

    add_index "katello_activation_keys", ["content_view_id"], :name => "index_activation_keys_on_content_view_id"
    add_index "katello_activation_keys", ["environment_id"], :name => "index_activation_keys_on_environment_id"
    add_index "katello_activation_keys", ["name", "organization_id"], :name => "index_activation_keys_on_name_and_organization_id", :unique => true
    add_index "katello_activation_keys", ["organization_id"], :name => "index_activation_keys_on_organization_id"
    add_index "katello_activation_keys", ["user_id"], :name => "index_activation_keys_on_user_id"

    create_table "katello_changeset_content_views", :force => true do |t|
      t.integer  "changeset_id"
      t.integer  "content_view_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end

    create_table "katello_changeset_users", :force => true do |t|
      t.integer  "changeset_id"
      t.integer  "user_id"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end

    add_index "katello_changeset_users", ["changeset_id"], :name => "index_changeset_users_on_changeset_id"
    add_index "katello_changeset_users", ["user_id"], :name => "index_changeset_users_on_user_id"

    create_table "katello_changesets", :force => true do |t|
      t.integer  "environment_id"
      t.string   "name"
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
      t.datetime "promotion_date"
      t.string   "state",          :default => "new",                :null => false
      t.integer  "task_status_id"
      t.text     "description"
      t.string   "type",           :default => "PromotionChangeset"
    end

    add_index "katello_changesets", ["environment_id"], :name => "index_changesets_on_environment_id"
    add_index "katello_changesets", ["name", "environment_id"], :name => "index_changesets_on_name_and_environment_id", :unique => true
    add_index "katello_changesets", ["task_status_id"], :name => "index_changesets_on_task_status_id"

    create_table "katello_component_content_views", :force => true do |t|
      t.integer  "content_view_definition_id"
      t.integer  "content_view_id"
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end

    add_index "katello_component_content_views", ["content_view_definition_id", "content_view_id"], :name => "component_content_views_index"

    create_table "katello_content_view_definition_bases", :force => true do |t|
      t.string   "name"
      t.string   "label",                              :null => false
      t.text     "description"
      t.integer  "organization_id"
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
      t.boolean  "composite",       :default => false, :null => false
      t.string   "type"
      t.integer  "source_id"
    end

    add_index "katello_content_view_definition_bases", ["name", "organization_id"], :name => "index_content_view_definitions_on_name_and_organization_id"

    create_table "katello_content_view_definition_products", :force => true do |t|
      t.integer  "content_view_definition_id"
      t.integer  "product_id"
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end

    add_index "katello_content_view_definition_products", ["content_view_definition_id", "product_id"], :name => "content_view_def_product_index"

    create_table "katello_content_view_definition_repositories", :force => true do |t|
      t.integer  "content_view_definition_id"
      t.integer  "repository_id"
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end

    add_index "katello_content_view_definition_repositories", ["content_view_definition_id", "repository_id"], :name => "cvd_repo_index"

    create_table "katello_content_view_environments", :force => true do |t|
      t.string   "name"
      t.string   "label",           :null => false
      t.string   "cp_id"
      t.integer  "content_view_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "environment_id",  :null => false
    end

    add_index "katello_content_view_environments", ["content_view_id"], :name => "index_content_view_environments_on_content_view_id"
    add_index "katello_content_view_environments", ["cp_id"], :name => "index_cve_cp_id", :unique => true
    add_index "katello_content_view_environments", ["environment_id", "content_view_id"], :name => "index_cve_eid_cv_id", :unique => true
    add_index "katello_content_view_environments", ["environment_id"], :name => "index_content_view_environments_on_environment_id"

    create_table "katello_content_view_version_environments", :force => true do |t|
      t.integer  "content_view_version_id"
      t.integer  "environment_id"
      t.datetime "created_at",              :null => false
      t.datetime "updated_at",              :null => false
    end

    add_index "katello_content_view_version_environments", ["content_view_version_id", "environment_id"], :name => "cvv_env_index", :unique => true

    create_table "katello_content_view_versions", :force => true do |t|
      t.integer  "content_view_id"
      t.integer  "version",               :null => false
      t.datetime "created_at",            :null => false
      t.datetime "updated_at",            :null => false
      t.integer  "definition_archive_id"
    end

    add_index "katello_content_view_versions", ["id", "content_view_id"], :name => "cvv_cv_index"

    create_table "katello_content_views", :force => true do |t|
      t.string   "name"
      t.string   "label",                                         :null => false
      t.text     "description"
      t.integer  "content_view_definition_id"
      t.integer  "organization_id"
      t.boolean  "default",                    :default => false, :null => false
      t.datetime "created_at",                                    :null => false
      t.datetime "updated_at",                                    :null => false
    end

    add_index "katello_content_views", ["content_view_definition_id"], :name => "index_content_views_on_content_view_definition_id"
    add_index "katello_content_views", ["name", "organization_id"], :name => "index_content_views_on_name_and_organization_id"
    add_index "katello_content_views", ["organization_id", "label"], :name => "index_content_views_on_organization_id_and_label", :unique => true
    add_index "katello_content_views", ["organization_id"], :name => "index_content_views_on_organization_id"

    create_table "katello_custom_info", :force => true do |t|
      t.string   "keyname"
      t.string   "value",           :default => ""
      t.integer  "informable_id"
      t.string   "informable_type"
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
      t.boolean  "org_default",     :default => false
    end

    add_index "katello_custom_info", ["informable_type", "informable_id", "keyname"], :name => "index_custom_info_on_type_id_keyname"

    create_table "katello_delayed_jobs", :force => true do |t|
      t.integer  "priority",   :default => 0
      t.integer  "attempts",   :default => 0
      t.text     "handler"
      t.text     "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
      t.string   "queue"
    end

    add_index "katello_delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

    create_table "katello_distributors", :force => true do |t|
      t.string   "uuid"
      t.string   "name"
      t.text     "description"
      t.string   "location"
      t.integer  "environment_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "content_view_id"
    end

    add_index "katello_distributors", ["content_view_id"], :name => "index_distributors_on_content_view_id"
    add_index "katello_distributors", ["environment_id"], :name => "index_distributors_on_environment_id"

    create_table "katello_environment_priors", :id => false, :force => true do |t|
      t.integer "environment_id"
      t.integer "prior_id",       :null => false
    end

    add_index "katello_environment_priors", ["environment_id"], :name => "index_environment_priors_on_environment_id"
    add_index "katello_environment_priors", ["prior_id"], :name => "index_environment_priors_on_prior_id"

    create_table "katello_environment_system_groups", :force => true do |t|
      t.integer "environment_id"
      t.integer "system_group_id"
    end

    add_index "katello_environment_system_groups", ["environment_id"], :name => "index_environment_system_groups_on_environment_id"
    add_index "katello_environment_system_groups", ["system_group_id"], :name => "index_environment_system_groups_on_system_group_id"

    create_table "katello_environments", :force => true do |t|
      t.string   "name",                               :null => false
      t.text     "description"
      t.boolean  "library",         :default => false, :null => false
      t.integer  "organization_id",                    :null => false
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
      t.string   "label",                              :null => false
    end

    add_index "katello_environments", ["label", "organization_id"], :name => "index_environments_on_label_and_organization_id", :unique => true
    add_index "katello_environments", ["name", "organization_id"], :name => "index_environments_on_name_and_organization_id", :unique => true
    add_index "katello_environments", ["organization_id"], :name => "index_environments_on_organization_id"

    create_table "katello_filter_rules", :force => true do |t|
      t.string   "type"
      t.text     "parameters"
      t.integer  "filter_id",                    :null => false
      t.boolean  "inclusion",  :default => true
      t.datetime "created_at",                   :null => false
      t.datetime "updated_at",                   :null => false
    end

    add_index "katello_filter_rules", ["filter_id"], :name => "index_filter_rules_on_filter_id"

    create_table "katello_filters", :force => true do |t|
      t.integer  "content_view_definition_id"
      t.string   "name",                       :null => false
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end

    add_index "katello_filters", ["content_view_definition_id"], :name => "index_filters_on_content_view_definition_id"
    add_index "katello_filters", ["name", "content_view_definition_id"], :name => "index_filters_on_name_and_content_view_definition_id", :unique => true

    create_table "katello_filters_products", :id => false, :force => true do |t|
      t.integer "filter_id"
      t.integer "product_id"
    end

    add_index "katello_filters_products", ["filter_id", "product_id"], :name => "index_filters_products_on_filter_id_and_product_id", :unique => true
    add_index "katello_filters_products", ["filter_id"], :name => "index_filters_products_on_filter_id"
    add_index "katello_filters_products", ["product_id"], :name => "index_filters_products_on_product_id"

    create_table "katello_filters_repositories", :id => false, :force => true do |t|
      t.integer "filter_id"
      t.integer "repository_id"
    end

    add_index "katello_filters_repositories", ["filter_id", "repository_id"], :name => "index_filters_repositories_on_filter_id_and_repository_id", :unique => true
    add_index "katello_filters_repositories", ["filter_id"], :name => "index_filters_repositories_on_filter_id"
    add_index "katello_filters_repositories", ["repository_id"], :name => "index_filters_repositories_on_repository_id"

    create_table "katello_gpg_keys", :force => true do |t|
      t.string   "name",            :null => false
      t.integer  "organization_id", :null => false
      t.text     "content",         :null => false
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end

    add_index "katello_gpg_keys", ["organization_id", "name"], :name => "index_gpg_keys_on_organization_id_and_name", :unique => true

    create_table "katello_help_tips", :force => true do |t|
      t.string   "key"
      t.integer  "user_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_help_tips", ["user_id"], :name => "index_help_tips_on_user_id"

    create_table "katello_job_tasks", :force => true do |t|
      t.integer "job_id"
      t.integer "task_status_id"
    end

    add_index "katello_job_tasks", ["job_id"], :name => "index_job_tasks_on_job_id"
    add_index "katello_job_tasks", ["task_status_id"], :name => "index_job_tasks_on_task_status_id"

    create_table "katello_jobs", :force => true do |t|
      t.integer "job_owner_id"
      t.string  "job_owner_type"
      t.string  "pulp_id",        :null => false
    end

    add_index "katello_jobs", ["job_owner_id"], :name => "index_jobs_on_job_owner_id"
    add_index "katello_jobs", ["pulp_id"], :name => "index_jobs_on_pulp_id"

    create_table "katello_key_pools", :force => true do |t|
      t.integer "activation_key_id"
      t.integer "pool_id"
    end

    add_index "katello_key_pools", ["activation_key_id"], :name => "index_key_pools_on_activation_key_id"
    add_index "katello_key_pools", ["pool_id"], :name => "index_key_pools_on_pool_id"

    create_table "katello_key_system_groups", :force => true do |t|
      t.integer "activation_key_id"
      t.integer "system_group_id"
    end

    add_index "katello_key_system_groups", ["activation_key_id"], :name => "index_key_system_groups_on_activation_key_id"
    add_index "katello_key_system_groups", ["system_group_id"], :name => "index_key_system_groups_on_system_group_id"

    create_table "katello_ldap_group_roles", :force => true do |t|
      t.string   "ldap_group"
      t.integer  "role_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_ldap_group_roles", ["ldap_group", "role_id"], :name => "index_ldap_group_roles_on_ldap_group_and_role_id", :unique => true
    add_index "katello_ldap_group_roles", ["role_id"], :name => "index_ldap_group_roles_on_role_id"

    create_table "katello_marketing_engineering_products", :force => true do |t|
      t.integer "marketing_product_id"
      t.integer "engineering_product_id"
    end

    add_index "katello_marketing_engineering_products", ["engineering_product_id"], :name => "index_marketing_engineering_products_on_engineering_product_id"
    add_index "katello_marketing_engineering_products", ["marketing_product_id"], :name => "index_marketing_engineering_products_on_marketing_product_id"

    create_table "katello_notices", :force => true do |t|
      t.string   "text",            :limit => 1024,                    :null => false
      t.text     "details"
      t.boolean  "global",                          :default => false, :null => false
      t.string   "level",                                              :null => false
      t.datetime "created_at",                                         :null => false
      t.datetime "updated_at",                                         :null => false
      t.string   "request_type"
      t.integer  "organization_id"
    end

    add_index "katello_notices", ["organization_id"], :name => "index_notices_on_organization_id"

    create_table "katello_organizations", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.string   "label"
      t.datetime "created_at",                            :null => false
      t.datetime "updated_at",                            :null => false
      t.integer  "deletion_task_id"
      t.text     "default_info"
      t.integer  "apply_info_task_id"
      t.integer  "owner_auto_attach_all_systems_task_id"
    end

    add_index "katello_organizations", ["deletion_task_id"], :name => "index_organizations_on_task_id"
    add_index "katello_organizations", ["label"], :name => "index_organizations_on_cp_key", :unique => true
    add_index "katello_organizations", ["name"], :name => "index_organizations_on_name", :unique => true

    create_table "katello_organizations_users", :id => false, :force => true do |t|
      t.integer "organization_id"
      t.integer "user_id"
    end

    add_index "katello_organizations_users", ["organization_id"], :name => "index_organizations_users_on_organization_id"
    add_index "katello_organizations_users", ["user_id"], :name => "index_organizations_users_on_user_id"

    create_table "katello_permission_tags", :force => true do |t|
      t.integer  "permission_id"
      t.integer  "tag_id"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end

    add_index "katello_permission_tags", ["permission_id"], :name => "index_permission_tags_on_permission_id"
    add_index "katello_permission_tags", ["tag_id"], :name => "index_permission_tags_on_tag_id"

    create_table "katello_permissions", :force => true do |t|
      t.integer  "role_id"
      t.integer  "resource_type_id"
      t.integer  "organization_id"
      t.boolean  "all_tags",         :default => false
      t.boolean  "all_verbs",        :default => false
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.string   "name",             :default => ""
      t.text     "description",      :default => ""
    end

    add_index "katello_permissions", ["name", "organization_id", "role_id"], :name => "index_permissions_on_name_and_organization_id_and_role_id", :unique => true
    add_index "katello_permissions", ["organization_id"], :name => "index_permissions_on_organization_id"
    add_index "katello_permissions", ["resource_type_id"], :name => "index_permissions_on_resource_type_id"
    add_index "katello_permissions", ["role_id"], :name => "index_permissions_on_role_id"

    create_table "katello_permissions_verbs", :id => false, :force => true do |t|
      t.integer "permission_id"
      t.integer "verb_id"
    end

    add_index "katello_permissions_verbs", ["permission_id"], :name => "index_permissions_verbs_on_permission_id"
    add_index "katello_permissions_verbs", ["verb_id"], :name => "index_permissions_verbs_on_verb_id"

    create_table "katello_pools", :force => true do |t|
      t.string   "cp_id",      :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_pools", ["cp_id"], :name => "index_pools_on_cp_id"

    create_table "katello_products", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.string   "cp_id"
      t.integer  "multiplier"
      t.integer  "provider_id",                               :null => false
      t.datetime "created_at",                                :null => false
      t.datetime "updated_at",                                :null => false
      t.integer  "gpg_key_id"
      t.string   "type",               :default => "Product", :null => false
      t.integer  "sync_plan_id"
      t.string   "label",                                     :null => false
      t.boolean  "cdn_import_success", :default => true,      :null => false
    end

    add_index "katello_products", ["cp_id"], :name => "index_products_on_cp_id"
    add_index "katello_products", ["gpg_key_id"], :name => "index_products_on_gpg_key_id"
    add_index "katello_products", ["provider_id"], :name => "index_products_on_provider_id"
    add_index "katello_products", ["sync_plan_id"], :name => "index_products_on_sync_plan_id"

    create_table "katello_providers", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.string   "repository_url"
      t.string   "provider_type"
      t.integer  "organization_id"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.integer  "task_status_id"
      t.string   "discovery_url"
      t.text     "discovered_repos"
      t.integer  "discovery_task_id"
    end

    add_index "katello_providers", ["name", "organization_id"], :name => "index_providers_on_name_and_organization_id", :unique => true
    add_index "katello_providers", ["organization_id"], :name => "index_providers_on_organization_id"
    add_index "katello_providers", ["task_status_id"], :name => "index_providers_on_task_status_id"

    create_table "katello_repositories", :force => true do |t|
      t.string   "name"
      t.string   "pulp_id",                                       :null => false
      t.boolean  "enabled",                 :default => true
      t.datetime "created_at",                                    :null => false
      t.datetime "updated_at",                                    :null => false
      t.integer  "major"
      t.string   "minor"
      t.integer  "gpg_key_id"
      t.string   "cp_label"
      t.integer  "library_instance_id"
      t.string   "content_id",                                    :null => false
      t.string   "arch",                    :default => "noarch", :null => false
      t.string   "label",                                         :null => false
      t.integer  "content_view_version_id",                       :null => false
      t.string   "relative_path",                                 :null => false
      t.string   "feed"
      t.boolean  "unprotected",             :default => false,    :null => false
      t.string   "content_type",            :default => "yum",    :null => false
      t.integer  "product_id"
      t.integer  "environment_id"
    end

    add_index "katello_repositories", ["content_view_version_id"], :name => "index_repositories_on_content_view_version_id"
    add_index "katello_repositories", ["cp_label"], :name => "index_repositories_on_cp_label"
    add_index "katello_repositories", ["environment_id"], :name => "index_repositories_on_environment_id"
    add_index "katello_repositories", ["gpg_key_id"], :name => "index_repositories_on_gpg_key_id"
    add_index "katello_repositories", ["library_instance_id"], :name => "index_repositories_on_library_instance_id"
    add_index "katello_repositories", ["product_id"], :name => "index_repositories_on_product_id"
    add_index "katello_repositories", ["pulp_id"], :name => "index_repositories_on_pulp_id"

    create_table "katello_resource_types", :force => true do |t|
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "katello_roles", :force => true do |t|
      t.string   "name"
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
      t.text     "description"
      t.boolean  "locked",      :default => false
      t.string   "type"
    end

    add_index "katello_roles", ["name"], :name => "index_roles_on_name", :unique => true

    create_table "katello_roles_users", :force => true do |t|
      t.integer "role_id"
      t.integer "user_id"
      t.boolean "ldap"
    end

    add_index "katello_roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
    add_index "katello_roles_users", ["user_id", "role_id"], :name => "index_roles_users_on_user_id_and_role_id", :unique => true
    add_index "katello_roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

    create_table "katello_search_favorites", :force => true do |t|
      t.string   "params"
      t.string   "path"
      t.integer  "user_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_search_favorites", ["user_id"], :name => "index_search_favorites_on_user_id"

    create_table "katello_search_histories", :force => true do |t|
      t.string   "params"
      t.string   "path"
      t.integer  "user_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_search_histories", ["user_id"], :name => "index_search_histories_on_user_id"

    create_table "katello_sync_plans", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.datetime "sync_date"
      t.string   "interval"
      t.integer  "organization_id", :null => false
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end

    add_index "katello_sync_plans", ["name", "organization_id"], :name => "index_sync_plans_on_name_and_organization_id", :unique => true
    add_index "katello_sync_plans", ["organization_id"], :name => "index_sync_plans_on_organization_id"

    create_table "katello_system_activation_keys", :force => true do |t|
      t.integer "system_id"
      t.integer "activation_key_id"
    end

    add_index "katello_system_activation_keys", ["activation_key_id"], :name => "index_system_activation_keys_on_activation_key_id"
    add_index "katello_system_activation_keys", ["system_id"], :name => "index_system_activation_keys_on_system_id"

    create_table "katello_system_groups", :force => true do |t|
      t.string   "name",                            :null => false
      t.string   "pulp_id",                         :null => false
      t.text     "description"
      t.integer  "max_systems",     :default => -1, :null => false
      t.integer  "organization_id",                 :null => false
      t.datetime "created_at",                      :null => false
      t.datetime "updated_at",                      :null => false
    end

    add_index "katello_system_groups", ["name", "organization_id"], :name => "index_system_groups_on_name_and_organization_id", :unique => true
    add_index "katello_system_groups", ["organization_id"], :name => "index_system_groups_on_organization_id"
    add_index "katello_system_groups", ["pulp_id"], :name => "index_system_groups_on_pulp_id"

    create_table "katello_system_system_groups", :force => true do |t|
      t.integer  "system_id"
      t.integer  "system_group_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end

    add_index "katello_system_system_groups", ["system_group_id"], :name => "index_system_system_groups_on_system_group_id"
    add_index "katello_system_system_groups", ["system_id"], :name => "index_system_system_groups_on_system_id"

    create_table "katello_systems", :force => true do |t|
      t.string   "uuid"
      t.string   "name"
      t.text     "description"
      t.string   "location"
      t.integer  "environment_id"
      t.datetime "created_at",                            :null => false
      t.datetime "updated_at",                            :null => false
      t.string   "type",            :default => "System"
      t.integer  "content_view_id"
    end

    add_index "katello_systems", ["content_view_id"], :name => "index_systems_on_content_view_id"
    add_index "katello_systems", ["environment_id"], :name => "index_systems_on_environment_id"

    create_table "katello_task_statuses", :force => true do |t|
      t.string   "type"
      t.integer  "organization_id"
      t.string   "uuid",                           :null => false
      t.string   "state"
      t.text     "result"
      t.text     "progress"
      t.datetime "start_time"
      t.datetime "finish_time"
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
      t.text     "parameters"
      t.string   "task_type"
      t.integer  "user_id",         :default => 0, :null => false
      t.integer  "task_owner_id"
      t.string   "task_owner_type"
    end

    add_index "katello_task_statuses", ["organization_id"], :name => "index_task_statuses_on_organization_id"
    add_index "katello_task_statuses", ["task_owner_id"], :name => "index_task_statuses_on_task_owner_id"
    add_index "katello_task_statuses", ["user_id"], :name => "index_task_statuses_on_user_id"
    add_index "katello_task_statuses", ["uuid"], :name => "index_task_statuses_on_uuid"

    create_table "katello_user_notices", :force => true do |t|
      t.integer "user_id"
      t.integer "notice_id"
      t.boolean "viewed",    :default => false, :null => false
    end

    add_index "katello_user_notices", ["notice_id"], :name => "index_user_notices_on_notice_id"
    add_index "katello_user_notices", ["user_id"], :name => "index_user_notices_on_user_id"

    create_table "katello_users", :force => true do |t|
      t.string   "username"
      t.string   "password"
      t.boolean  "helptips_enabled",       :default => true
      t.boolean  "hidden",                 :default => false, :null => false
      t.datetime "created_at",                                :null => false
      t.datetime "updated_at",                                :null => false
      t.integer  "page_size",              :default => 25,    :null => false
      t.boolean  "disabled",               :default => false
      t.string   "email"
      t.string   "password_reset_token"
      t.datetime "password_reset_sent_at"
      t.text     "preferences"
      t.integer  "foreman_id"
      t.string   "remote_id"
      t.integer  "default_environment_id"
    end

    add_index "katello_users", ["remote_id"], :name => "index_users_on_remote_id", :unique => true
    add_index "katello_users", ["username"], :name => "index_users_on_username", :unique => true

    create_table "katello_verbs", :force => true do |t|
      t.string   "verb"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end

  def self.down
    drop_table "katello_activation_keys"
    drop_table "katello_changeset_content_views"
    drop_table "katello_changeset_users"
    drop_table "katello_changesets"
    drop_table "katello_component_content_views"
    drop_table "katello_content_view_definition_bases"
    drop_table "katello_content_view_definition_products"
    drop_table "katello_content_view_definition_repositories"
    drop_table "katello_content_view_environments"
    drop_table "katello_content_view_version_environments"
    drop_table "katello_content_view_versions"
    drop_table "katello_content_views"
    drop_table "katello_custom_info"
    drop_table "katello_delayed_jobs"
    drop_table "katello_distributors"
    drop_table "katello_environment_priors"
    drop_table "katello_environment_system_groups"
    drop_table "katello_environments"
    drop_table "katello_filter_rules"
    drop_table "katello_filters"
    drop_table "katello_filters_products"
    drop_table "katello_filters_repositories"
    drop_table "katello_gpg_keys"
    drop_table "katello_help_tips"
    drop_table "katello_job_tasks"
    drop_table "katello_jobs"
    drop_table "katello_key_pools"
    drop_table "katello_key_system_groups"
    drop_table "katello_ldap_group_roles"
    drop_table "katello_marketing_engineering_products"
    drop_table "katello_notices"
    drop_table "katello_organizations"
    drop_table "katello_organizations_users"
    drop_table "katello_permission_tags"
    drop_table "katello_permissions"
    drop_table "katello_permissions_verbs"
    drop_table "katello_pools"
    drop_table "katello_products"
    drop_table "katello_providers"
    drop_table "katello_repositories"
    drop_table "katello_resource_types"
    drop_table "katello_roles"
    drop_table "katello_roles_users"
    drop_table "katello_search_favorites"
    drop_table "katello_search_histories"
    drop_table "katello_sync_plans"
    drop_table "katello_system_activation_keys"
    drop_table "katello_system_groups"
    drop_table "katello_system_system_groups"
    drop_table "katello_systems"
    drop_table "katello_task_statuses"
    drop_table "katello_user_notices"
    drop_table "katello_users"
    drop_table "katello_verbs"
  end

end
