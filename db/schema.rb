# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130715153703) do

  create_table "activation_keys", :force => true do |t|
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

  add_index "activation_keys", ["content_view_id"], :name => "index_activation_keys_on_content_view_id"
  add_index "activation_keys", ["environment_id"], :name => "index_activation_keys_on_environment_id"
  add_index "activation_keys", ["name", "organization_id"], :name => "index_activation_keys_on_name_and_organization_id", :unique => true
  add_index "activation_keys", ["organization_id"], :name => "index_activation_keys_on_organization_id"
  add_index "activation_keys", ["user_id"], :name => "index_activation_keys_on_user_id"

  create_table "changeset_content_views", :force => true do |t|
    t.integer  "changeset_id"
    t.integer  "content_view_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "changeset_users", :force => true do |t|
    t.integer  "changeset_id"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "changeset_users", ["changeset_id"], :name => "index_changeset_users_on_changeset_id"
  add_index "changeset_users", ["user_id"], :name => "index_changeset_users_on_user_id"

  create_table "changesets", :force => true do |t|
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

  add_index "changesets", ["environment_id"], :name => "index_changesets_on_environment_id"
  add_index "changesets", ["name", "environment_id"], :name => "index_changesets_on_name_and_environment_id", :unique => true
  add_index "changesets", ["task_status_id"], :name => "index_changesets_on_task_status_id"

  create_table "component_content_views", :force => true do |t|
    t.integer  "content_view_definition_id"
    t.integer  "content_view_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "component_content_views", ["content_view_definition_id", "content_view_id"], :name => "component_content_views_index"

  create_table "content_view_definition_bases", :force => true do |t|
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

  add_index "content_view_definition_bases", ["name", "organization_id"], :name => "index_content_view_definitions_on_name_and_organization_id"

  create_table "content_view_definition_products", :force => true do |t|
    t.integer  "content_view_definition_id"
    t.integer  "product_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "content_view_definition_products", ["content_view_definition_id", "product_id"], :name => "content_view_def_product_index"

  create_table "content_view_definition_repositories", :force => true do |t|
    t.integer  "content_view_definition_id"
    t.integer  "repository_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "content_view_definition_repositories", ["content_view_definition_id", "repository_id"], :name => "cvd_repo_index"

  create_table "content_view_environments", :force => true do |t|
    t.string   "name"
    t.string   "label",           :null => false
    t.string   "cp_id"
    t.integer  "content_view_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "environment_id",  :null => false
  end

  add_index "content_view_environments", ["content_view_id"], :name => "index_content_view_environments_on_content_view_id"
  add_index "content_view_environments", ["cp_id"], :name => "index_cve_cp_id", :unique => true
  add_index "content_view_environments", ["environment_id", "content_view_id"], :name => "index_cve_eid_cv_id", :unique => true
  add_index "content_view_environments", ["environment_id"], :name => "index_content_view_environments_on_environment_id"

  create_table "content_view_version_environments", :force => true do |t|
    t.integer  "content_view_version_id"
    t.integer  "environment_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "content_view_version_environments", ["content_view_version_id", "environment_id"], :name => "cvv_env_index", :unique => true

  create_table "content_view_versions", :force => true do |t|
    t.integer  "content_view_id"
    t.integer  "version",               :null => false
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "definition_archive_id"
  end

  add_index "content_view_versions", ["id", "content_view_id"], :name => "cvv_cv_index"

  create_table "content_views", :force => true do |t|
    t.string   "name"
    t.string   "label",                                         :null => false
    t.text     "description"
    t.integer  "content_view_definition_id"
    t.integer  "organization_id"
    t.boolean  "default",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "content_views", ["content_view_definition_id"], :name => "index_content_views_on_content_view_definition_id"
  add_index "content_views", ["name", "organization_id"], :name => "index_content_views_on_name_and_organization_id"
  add_index "content_views", ["organization_id", "label"], :name => "index_content_views_on_organization_id_and_label", :unique => true
  add_index "content_views", ["organization_id"], :name => "index_content_views_on_organization_id"

  create_table "custom_info", :force => true do |t|
    t.string   "keyname"
    t.string   "value",           :default => ""
    t.integer  "informable_id"
    t.string   "informable_type"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "org_default",     :default => false
  end

  add_index "custom_info", ["informable_type", "informable_id", "keyname"], :name => "index_custom_info_on_type_id_keyname"

  create_table "delayed_jobs", :force => true do |t|
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

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "distributors", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.text     "description"
    t.string   "location"
    t.integer  "environment_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "content_view_id"
  end

  add_index "distributors", ["content_view_id"], :name => "index_distributors_on_content_view_id"
  add_index "distributors", ["environment_id"], :name => "index_distributors_on_environment_id"

  create_table "environment_priors", :id => false, :force => true do |t|
    t.integer "environment_id"
    t.integer "prior_id",       :null => false
  end

  add_index "environment_priors", ["environment_id"], :name => "index_environment_priors_on_environment_id"
  add_index "environment_priors", ["prior_id"], :name => "index_environment_priors_on_prior_id"

  create_table "environment_system_groups", :force => true do |t|
    t.integer "environment_id"
    t.integer "system_group_id"
  end

  add_index "environment_system_groups", ["environment_id"], :name => "index_environment_system_groups_on_environment_id"
  add_index "environment_system_groups", ["system_group_id"], :name => "index_environment_system_groups_on_system_group_id"

  create_table "environments", :force => true do |t|
    t.string   "name",                               :null => false
    t.text     "description"
    t.boolean  "library",         :default => false, :null => false
    t.integer  "organization_id",                    :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "label",                              :null => false
  end

  add_index "environments", ["label", "organization_id"], :name => "index_environments_on_label_and_organization_id", :unique => true
  add_index "environments", ["name", "organization_id"], :name => "index_environments_on_name_and_organization_id", :unique => true
  add_index "environments", ["organization_id"], :name => "index_environments_on_organization_id"

  create_table "filter_rules", :force => true do |t|
    t.string   "type"
    t.text     "parameters"
    t.integer  "filter_id",                    :null => false
    t.boolean  "inclusion",  :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "filter_rules", ["filter_id"], :name => "index_filter_rules_on_filter_id"

  create_table "filters", :force => true do |t|
    t.integer  "content_view_definition_id"
    t.string   "name",                       :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "filters", ["content_view_definition_id"], :name => "index_filters_on_content_view_definition_id"
  add_index "filters", ["name", "content_view_definition_id"], :name => "index_filters_on_name_and_content_view_definition_id", :unique => true

  create_table "filters_products", :id => false, :force => true do |t|
    t.integer "filter_id"
    t.integer "product_id"
  end

  add_index "filters_products", ["filter_id", "product_id"], :name => "index_filters_products_on_filter_id_and_product_id", :unique => true
  add_index "filters_products", ["filter_id"], :name => "index_filters_products_on_filter_id"
  add_index "filters_products", ["product_id"], :name => "index_filters_products_on_product_id"

  create_table "filters_repositories", :id => false, :force => true do |t|
    t.integer "filter_id"
    t.integer "repository_id"
  end

  add_index "filters_repositories", ["filter_id", "repository_id"], :name => "index_filters_repositories_on_filter_id_and_repository_id", :unique => true
  add_index "filters_repositories", ["filter_id"], :name => "index_filters_repositories_on_filter_id"
  add_index "filters_repositories", ["repository_id"], :name => "index_filters_repositories_on_repository_id"

  create_table "gpg_keys", :force => true do |t|
    t.string   "name",            :null => false
    t.integer  "organization_id", :null => false
    t.text     "content",         :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "gpg_keys", ["organization_id", "name"], :name => "index_gpg_keys_on_organization_id_and_name", :unique => true

  create_table "help_tips", :force => true do |t|
    t.string   "key"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "help_tips", ["user_id"], :name => "index_help_tips_on_user_id"

  create_table "job_tasks", :force => true do |t|
    t.integer "job_id"
    t.integer "task_status_id"
  end

  add_index "job_tasks", ["job_id"], :name => "index_job_tasks_on_job_id"
  add_index "job_tasks", ["task_status_id"], :name => "index_job_tasks_on_task_status_id"

  create_table "jobs", :force => true do |t|
    t.integer "job_owner_id"
    t.string  "job_owner_type"
    t.string  "pulp_id",        :null => false
  end

  add_index "jobs", ["job_owner_id"], :name => "index_jobs_on_job_owner_id"
  add_index "jobs", ["pulp_id"], :name => "index_jobs_on_pulp_id"

  create_table "key_pools", :force => true do |t|
    t.integer "activation_key_id"
    t.integer "pool_id"
  end

  add_index "key_pools", ["activation_key_id"], :name => "index_key_pools_on_activation_key_id"
  add_index "key_pools", ["pool_id"], :name => "index_key_pools_on_pool_id"

  create_table "key_system_groups", :force => true do |t|
    t.integer "activation_key_id"
    t.integer "system_group_id"
  end

  add_index "key_system_groups", ["activation_key_id"], :name => "index_key_system_groups_on_activation_key_id"
  add_index "key_system_groups", ["system_group_id"], :name => "index_key_system_groups_on_system_group_id"

  create_table "ldap_group_roles", :force => true do |t|
    t.string   "ldap_group"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ldap_group_roles", ["ldap_group", "role_id"], :name => "index_ldap_group_roles_on_ldap_group_and_role_id", :unique => true
  add_index "ldap_group_roles", ["role_id"], :name => "index_ldap_group_roles_on_role_id"

  create_table "marketing_engineering_products", :force => true do |t|
    t.integer "marketing_product_id"
    t.integer "engineering_product_id"
  end

  add_index "marketing_engineering_products", ["engineering_product_id"], :name => "index_marketing_engineering_products_on_engineering_product_id"
  add_index "marketing_engineering_products", ["marketing_product_id"], :name => "index_marketing_engineering_products_on_marketing_product_id"

  create_table "notices", :force => true do |t|
    t.string   "text",            :limit => 1024,                    :null => false
    t.text     "details"
    t.boolean  "global",                          :default => false, :null => false
    t.string   "level",                                              :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "request_type"
    t.integer  "organization_id"
  end

  add_index "notices", ["organization_id"], :name => "index_notices_on_organization_id"

  create_table "organizations", :force => true do |t|
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

  add_index "organizations", ["deletion_task_id"], :name => "index_organizations_on_task_id"
  add_index "organizations", ["label"], :name => "index_organizations_on_cp_key", :unique => true
  add_index "organizations", ["name"], :name => "index_organizations_on_name", :unique => true

  create_table "organizations_users", :id => false, :force => true do |t|
    t.integer "organization_id"
    t.integer "user_id"
  end

  add_index "organizations_users", ["organization_id"], :name => "index_organizations_users_on_organization_id"
  add_index "organizations_users", ["user_id"], :name => "index_organizations_users_on_user_id"

  create_table "permission_tags", :force => true do |t|
    t.integer  "permission_id"
    t.integer  "tag_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "permission_tags", ["permission_id"], :name => "index_permission_tags_on_permission_id"
  add_index "permission_tags", ["tag_id"], :name => "index_permission_tags_on_tag_id"

  create_table "permissions", :force => true do |t|
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

  add_index "permissions", ["name", "organization_id", "role_id"], :name => "index_permissions_on_name_and_organization_id_and_role_id", :unique => true
  add_index "permissions", ["organization_id"], :name => "index_permissions_on_organization_id"
  add_index "permissions", ["resource_type_id"], :name => "index_permissions_on_resource_type_id"
  add_index "permissions", ["role_id"], :name => "index_permissions_on_role_id"

  create_table "permissions_verbs", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "verb_id"
  end

  add_index "permissions_verbs", ["permission_id"], :name => "index_permissions_verbs_on_permission_id"
  add_index "permissions_verbs", ["verb_id"], :name => "index_permissions_verbs_on_verb_id"

  create_table "pools", :force => true do |t|
    t.string   "cp_id",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pools", ["cp_id"], :name => "index_pools_on_cp_id"

  create_table "products", :force => true do |t|
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

  add_index "products", ["cp_id"], :name => "index_products_on_cp_id"
  add_index "products", ["gpg_key_id"], :name => "index_products_on_gpg_key_id"
  add_index "products", ["provider_id"], :name => "index_products_on_provider_id"
  add_index "products", ["sync_plan_id"], :name => "index_products_on_sync_plan_id"

  create_table "providers", :force => true do |t|
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

  add_index "providers", ["name", "organization_id"], :name => "index_providers_on_name_and_organization_id", :unique => true
  add_index "providers", ["organization_id"], :name => "index_providers_on_organization_id"
  add_index "providers", ["task_status_id"], :name => "index_providers_on_task_status_id"

  create_table "repositories", :force => true do |t|
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

  add_index "repositories", ["content_view_version_id"], :name => "index_repositories_on_content_view_version_id"
  add_index "repositories", ["cp_label"], :name => "index_repositories_on_cp_label"
  add_index "repositories", ["environment_id"], :name => "index_repositories_on_environment_id"
  add_index "repositories", ["gpg_key_id"], :name => "index_repositories_on_gpg_key_id"
  add_index "repositories", ["library_instance_id"], :name => "index_repositories_on_library_instance_id"
  add_index "repositories", ["product_id"], :name => "index_repositories_on_product_id"
  add_index "repositories", ["pulp_id"], :name => "index_repositories_on_pulp_id"

  create_table "resource_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.text     "description"
    t.boolean  "locked",      :default => false
    t.string   "type"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "roles_users", :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.boolean "ldap"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id", "role_id"], :name => "index_roles_users_on_user_id_and_role_id", :unique => true
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "search_favorites", :force => true do |t|
    t.string   "params"
    t.string   "path"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "search_favorites", ["user_id"], :name => "index_search_favorites_on_user_id"

  create_table "search_histories", :force => true do |t|
    t.string   "params"
    t.string   "path"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "search_histories", ["user_id"], :name => "index_search_histories_on_user_id"

  create_table "sync_plans", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "sync_date"
    t.string   "interval"
    t.integer  "organization_id", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "sync_plans", ["name", "organization_id"], :name => "index_sync_plans_on_name_and_organization_id", :unique => true
  add_index "sync_plans", ["organization_id"], :name => "index_sync_plans_on_organization_id"

  create_table "system_activation_keys", :force => true do |t|
    t.integer "system_id"
    t.integer "activation_key_id"
  end

  add_index "system_activation_keys", ["activation_key_id"], :name => "index_system_activation_keys_on_activation_key_id"
  add_index "system_activation_keys", ["system_id"], :name => "index_system_activation_keys_on_system_id"

  create_table "system_groups", :force => true do |t|
    t.string   "name",                            :null => false
    t.string   "pulp_id",                         :null => false
    t.text     "description"
    t.integer  "max_systems",     :default => -1, :null => false
    t.integer  "organization_id",                 :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "system_groups", ["name", "organization_id"], :name => "index_system_groups_on_name_and_organization_id", :unique => true
  add_index "system_groups", ["organization_id"], :name => "index_system_groups_on_organization_id"
  add_index "system_groups", ["pulp_id"], :name => "index_system_groups_on_pulp_id"

  create_table "system_system_groups", :force => true do |t|
    t.integer  "system_id"
    t.integer  "system_group_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "system_system_groups", ["system_group_id"], :name => "index_system_system_groups_on_system_group_id"
  add_index "system_system_groups", ["system_id"], :name => "index_system_system_groups_on_system_id"

  create_table "systems", :force => true do |t|
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

  add_index "systems", ["content_view_id"], :name => "index_systems_on_content_view_id"
  add_index "systems", ["environment_id"], :name => "index_systems_on_environment_id"

  create_table "task_statuses", :force => true do |t|
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

  add_index "task_statuses", ["organization_id"], :name => "index_task_statuses_on_organization_id"
  add_index "task_statuses", ["task_owner_id"], :name => "index_task_statuses_on_task_owner_id"
  add_index "task_statuses", ["user_id"], :name => "index_task_statuses_on_user_id"
  add_index "task_statuses", ["uuid"], :name => "index_task_statuses_on_uuid"

  create_table "user_notices", :force => true do |t|
    t.integer "user_id"
    t.integer "notice_id"
    t.boolean "viewed",    :default => false, :null => false
  end

  add_index "user_notices", ["notice_id"], :name => "index_user_notices_on_notice_id"
  add_index "user_notices", ["user_id"], :name => "index_user_notices_on_user_id"

  create_table "users", :force => true do |t|
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

  add_index "users", ["remote_id"], :name => "index_users_on_remote_id", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "verbs", :force => true do |t|
    t.string   "verb"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_foreign_key "activation_keys", "content_views", :name => "activation_keys_content_view_id_fk"
  add_foreign_key "activation_keys", "environments", :name => "activation_keys_environment_id_fk"
  add_foreign_key "activation_keys", "organizations", :name => "activation_keys_organization_id_fk"
  add_foreign_key "activation_keys", "users", :name => "activation_keys_user_id_fk"

  add_foreign_key "changeset_content_views", "changesets", :name => "changeset_content_views_changeset_id_fk"
  add_foreign_key "changeset_content_views", "content_views", :name => "changeset_content_views_content_view_id_fk"

  add_foreign_key "changeset_users", "changesets", :name => "changeset_users_changeset_id_fk"
  add_foreign_key "changeset_users", "users", :name => "changeset_users_user_id_fk"

  add_foreign_key "changesets", "environments", :name => "changesets_environment_id_fk"
  add_foreign_key "changesets", "task_statuses", :name => "changesets_task_status_id_fk"

  add_foreign_key "component_content_views", "content_view_definition_bases", :name => "component_content_views_content_view_definition_id_fk", :column => "content_view_definition_id"
  add_foreign_key "component_content_views", "content_views", :name => "component_content_views_content_view_id_fk"

  add_foreign_key "content_view_definition_bases", "content_view_definition_bases", :name => "content_view_definition_bases_source_id_fk", :column => "source_id"
  add_foreign_key "content_view_definition_bases", "organizations", :name => "content_view_definition_bases_organization_id_fk"

  add_foreign_key "content_view_definition_products", "content_view_definition_bases", :name => "content_view_definition_products_content_view_definition_id_fk", :column => "content_view_definition_id"
  add_foreign_key "content_view_definition_products", "products", :name => "content_view_definition_products_product_id_fk"

  add_foreign_key "content_view_definition_repositories", "content_view_definition_bases", :name => "CV_definition_repositories_CV_definition_id_fk", :column => "content_view_definition_id"
  add_foreign_key "content_view_definition_repositories", "repositories", :name => "content_view_definition_repositories_repository_id_fk"

  add_foreign_key "content_view_environments", "content_views", :name => "content_view_environments_content_view_id_fk"
  add_foreign_key "content_view_environments", "environments", :name => "content_view_environments_environment_id_fk"

  add_foreign_key "content_view_version_environments", "content_view_versions", :name => "content_view_version_environments_content_view_version_id_fk"
  add_foreign_key "content_view_version_environments", "environments", :name => "content_view_version_environments_environment_id_fk"

  add_foreign_key "content_view_versions", "content_view_definition_bases", :name => "content_view_versions_content_view_definition_archive_id_fk", :column => "definition_archive_id"
  add_foreign_key "content_view_versions", "content_view_definition_bases", :name => "content_view_versions_definition_archive_id_fk", :column => "definition_archive_id"
  add_foreign_key "content_view_versions", "content_views", :name => "content_view_versions_content_view_id_fk"

  add_foreign_key "content_views", "content_view_definition_bases", :name => "content_views_content_view_definition_id_fk", :column => "content_view_definition_id"
  add_foreign_key "content_views", "organizations", :name => "content_views_organization_id_fk"

  add_foreign_key "distributors", "content_views", :name => "distributors_content_view_id_fk"
  add_foreign_key "distributors", "environments", :name => "distributors_environment_id_fk"

  add_foreign_key "environment_priors", "environments", :name => "environment_priors_environment_id_fk"
  add_foreign_key "environment_priors", "environments", :name => "environment_priors_prior_id_fk", :column => "prior_id"

  add_foreign_key "environment_system_groups", "environments", :name => "environment_system_groups_environment_id_fk"
  add_foreign_key "environment_system_groups", "system_groups", :name => "environment_system_groups_system_group_id_fk"

  add_foreign_key "environments", "organizations", :name => "environments_organization_id_fk"

  add_foreign_key "filter_rules", "filters", :name => "filters_rules_filter_id_fk"

  add_foreign_key "filters", "content_view_definition_bases", :name => "filters_content_view_definition_id_fk", :column => "content_view_definition_id"

  add_foreign_key "filters_products", "filters", :name => "filters_product_filter_id_fk"
  add_foreign_key "filters_products", "products", :name => "filters_product_product_id_fk"

  add_foreign_key "filters_repositories", "filters", :name => "filters_repositories_filter_id_fk"
  add_foreign_key "filters_repositories", "repositories", :name => "filters_repositories_repository_id_fk"

  add_foreign_key "gpg_keys", "organizations", :name => "gpg_keys_organization_id_fk"

  add_foreign_key "help_tips", "users", :name => "help_tips_user_id_fk"

  add_foreign_key "job_tasks", "jobs", :name => "job_tasks_job_id_fk"
  add_foreign_key "job_tasks", "task_statuses", :name => "job_tasks_task_status_id_fk"

  add_foreign_key "key_pools", "activation_keys", :name => "key_pools_activation_key_id_fk"
  add_foreign_key "key_pools", "pools", :name => "key_pools_pool_id_fk"

  add_foreign_key "key_system_groups", "activation_keys", :name => "key_system_groups_activation_key_id_fk"
  add_foreign_key "key_system_groups", "system_groups", :name => "key_system_groups_system_group_id_fk"

  add_foreign_key "ldap_group_roles", "roles", :name => "ldap_group_roles_role_id_fk"

  add_foreign_key "marketing_engineering_products", "products", :name => "marketing_engineering_products_engineering_product_id_fk", :column => "engineering_product_id"
  add_foreign_key "marketing_engineering_products", "products", :name => "marketing_engineering_products_marketing_product_id_fk", :column => "marketing_product_id"

  add_foreign_key "notices", "organizations", :name => "notices_organization_id_fk"

  add_foreign_key "organizations", "task_statuses", :name => "organizations_apply_info_task_id_fk", :column => "apply_info_task_id"
  add_foreign_key "organizations", "task_statuses", :name => "organizations_deletion_task_id_fk", :column => "deletion_task_id"

  add_foreign_key "organizations_users", "organizations", :name => "organizations_users_organization_id_fk"
  add_foreign_key "organizations_users", "users", :name => "organizations_users_user_id_fk"

  add_foreign_key "permission_tags", "permissions", :name => "permission_tags_permission_id_fk"

  add_foreign_key "permissions", "organizations", :name => "permissions_organization_id_fk"
  add_foreign_key "permissions", "resource_types", :name => "permissions_resource_type_id_fk"
  add_foreign_key "permissions", "roles", :name => "permissions_role_id_fk"

  add_foreign_key "permissions_verbs", "permissions", :name => "permissions_verbs_permission_id_fk"
  add_foreign_key "permissions_verbs", "verbs", :name => "permissions_verbs_verb_id_fk"

  add_foreign_key "products", "gpg_keys", :name => "products_gpg_key_id_fk"
  add_foreign_key "products", "providers", :name => "products_provider_id_fk"
  add_foreign_key "products", "sync_plans", :name => "products_sync_plan_id_fk"

  add_foreign_key "providers", "organizations", :name => "providers_organization_id_fk"
  add_foreign_key "providers", "task_statuses", :name => "providers_discovery_task_id_fk", :column => "discovery_task_id"
  add_foreign_key "providers", "task_statuses", :name => "providers_task_status_id_fk"

  add_foreign_key "repositories", "content_view_versions", :name => "repositories_content_view_version_id_fk"
  add_foreign_key "repositories", "gpg_keys", :name => "repositories_gpg_key_id_fk"
  add_foreign_key "repositories", "repositories", :name => "repositories_library_instance_id_fk", :column => "library_instance_id"

  add_foreign_key "roles_users", "roles", :name => "roles_users_role_id_fk"
  add_foreign_key "roles_users", "users", :name => "roles_users_user_id_fk"

  add_foreign_key "search_favorites", "users", :name => "search_favorites_user_id_fk"

  add_foreign_key "search_histories", "users", :name => "search_histories_user_id_fk"

  add_foreign_key "sync_plans", "organizations", :name => "sync_plans_organization_id_fk"

  add_foreign_key "system_activation_keys", "activation_keys", :name => "system_activation_keys_activation_key_id_fk"
  add_foreign_key "system_activation_keys", "systems", :name => "system_activation_keys_system_id_fk"

  add_foreign_key "system_groups", "organizations", :name => "system_groups_organization_id_fk"

  add_foreign_key "system_system_groups", "system_groups", :name => "system_system_groups_system_group_id_fk"
  add_foreign_key "system_system_groups", "systems", :name => "system_system_groups_system_id_fk"

  add_foreign_key "systems", "content_views", :name => "systems_content_view_id_fk"
  add_foreign_key "systems", "environments", :name => "systems_environment_id_fk"

  add_foreign_key "task_statuses", "organizations", :name => "task_statuses_organization_id_fk"
  add_foreign_key "task_statuses", "users", :name => "task_statuses_user_id_fk"

  add_foreign_key "user_notices", "notices", :name => "user_notices_notice_id_fk"
  add_foreign_key "user_notices", "users", :name => "user_notices_user_id_fk"

  add_foreign_key "users", "environments", :name => "users_default_environment_id_fk", :column => "default_environment_id"

end
