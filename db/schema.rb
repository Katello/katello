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

ActiveRecord::Schema.define(:version => 20130226133232) do

  create_table "activation_keys", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "organization_id",                    :null => false
    t.integer  "environment_id",                     :null => false
    t.integer  "system_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "usage_limit",        :default => -1
    t.integer  "content_view_id"
  end

  add_index "activation_keys", ["content_view_id"], :name => "index_activation_keys_on_content_view_id"
  add_index "activation_keys", ["environment_id"], :name => "index_activation_keys_on_environment_id"
  add_index "activation_keys", ["name", "organization_id"], :name => "index_activation_keys_on_name_and_organization_id", :unique => true
  add_index "activation_keys", ["organization_id"], :name => "index_activation_keys_on_organization_id"
  add_index "activation_keys", ["system_template_id"], :name => "index_activation_keys_on_system_template_id"
  add_index "activation_keys", ["user_id"], :name => "index_activation_keys_on_user_id"

  create_table "changeset_content_views", :force => true do |t|
    t.integer  "changeset_id"
    t.integer  "content_view_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "changeset_dependencies", :force => true do |t|
    t.integer "changeset_id"
    t.string  "package_id"
    t.string  "display_name"
    t.integer "product_id",    :null => false
    t.string  "dependency_of"
  end

  add_index "changeset_dependencies", ["changeset_id"], :name => "index_changeset_dependencies_on_changeset_id"
  add_index "changeset_dependencies", ["package_id"], :name => "index_changeset_dependencies_on_package_id"
  add_index "changeset_dependencies", ["product_id"], :name => "index_changeset_dependencies_on_product_id"

  create_table "changeset_distributions", :force => true do |t|
    t.integer "changeset_id"
    t.string  "distribution_id"
    t.string  "display_name"
    t.integer "product_id",      :null => false
  end

  add_index "changeset_distributions", ["changeset_id"], :name => "index_changeset_distributions_on_changeset_id"
  add_index "changeset_distributions", ["distribution_id", "changeset_id", "product_id"], :name => "index_cs_distro_distro_id_cs_id_p_id", :unique => true
  add_index "changeset_distributions", ["distribution_id"], :name => "index_changeset_distributions_on_distribution_id"
  add_index "changeset_distributions", ["product_id"], :name => "index_changeset_distributions_on_product_id"

  create_table "changeset_errata", :force => true do |t|
    t.integer "changeset_id"
    t.string  "errata_id"
    t.string  "display_name"
    t.integer "product_id",   :null => false
  end

  add_index "changeset_errata", ["changeset_id"], :name => "index_changeset_errata_on_changeset_id"
  add_index "changeset_errata", ["errata_id", "changeset_id"], :name => "index_changeset_errata_on_errata_id_and_changeset_id", :unique => true
  add_index "changeset_errata", ["errata_id"], :name => "index_changeset_errata_on_errata_id"
  add_index "changeset_errata", ["product_id"], :name => "index_changeset_errata_on_product_id"

  create_table "changeset_packages", :force => true do |t|
    t.integer "changeset_id"
    t.string  "package_id"
    t.string  "display_name"
    t.integer "product_id",   :null => false
    t.string  "nvrea"
  end

  add_index "changeset_packages", ["changeset_id"], :name => "index_changeset_packages_on_changeset_id"
  add_index "changeset_packages", ["nvrea", "changeset_id"], :name => "index_changeset_packages_on_nvrea_and_changeset_id", :unique => true
  add_index "changeset_packages", ["package_id"], :name => "index_changeset_packages_on_package_id"
  add_index "changeset_packages", ["product_id"], :name => "index_changeset_packages_on_product_id"

  create_table "changeset_users", :force => true do |t|
    t.integer  "changeset_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "changeset_users", ["changeset_id"], :name => "index_changeset_users_on_changeset_id"
  add_index "changeset_users", ["user_id"], :name => "index_changeset_users_on_user_id"

  create_table "changesets", :force => true do |t|
    t.integer  "environment_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "promotion_date"
    t.string   "state",          :default => "new",                :null => false
    t.integer  "task_status_id"
    t.string   "description"
    t.string   "type",           :default => "PromotionChangeset"
  end

  add_index "changesets", ["environment_id"], :name => "index_changesets_on_environment_id"
  add_index "changesets", ["name", "environment_id"], :name => "index_changesets_on_name_and_environment_id", :unique => true
  add_index "changesets", ["task_status_id"], :name => "index_changesets_on_task_status_id"

  create_table "changesets_products", :id => false, :force => true do |t|
    t.integer "changeset_id"
    t.integer "product_id"
  end

  add_index "changesets_products", ["changeset_id"], :name => "index_changesets_products_on_changeset_id"
  add_index "changesets_products", ["product_id"], :name => "index_changesets_products_on_product_id"

  create_table "changesets_repositories", :id => false, :force => true do |t|
    t.integer "changeset_id",  :null => false
    t.integer "repository_id", :null => false
  end

  add_index "changesets_repositories", ["changeset_id"], :name => "index_changesets_repositories_on_changeset_id"
  add_index "changesets_repositories", ["repository_id"], :name => "index_changesets_repositories_on_repository_id"

  create_table "changesets_system_templates", :id => false, :force => true do |t|
    t.integer "changeset_id",       :null => false
    t.integer "system_template_id", :null => false
  end

  add_index "changesets_system_templates", ["changeset_id"], :name => "index_changesets_system_templates_on_changeset_id"
  add_index "changesets_system_templates", ["system_template_id"], :name => "index_changesets_system_templates_on_system_template_id"

  create_table "component_content_views", :force => true do |t|
    t.integer  "content_view_definition_id"
    t.integer  "content_view_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "component_content_views", ["content_view_definition_id", "content_view_id"], :name => "component_content_views_index"

  create_table "content_view_definition_products", :force => true do |t|
    t.integer  "content_view_definition_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_view_definition_products", ["content_view_definition_id", "product_id"], :name => "content_view_def_product_index"

  create_table "content_view_definition_repositories", :force => true do |t|
    t.integer  "content_view_definition_id"
    t.integer  "repository_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_view_definition_repositories", ["content_view_definition_id", "repository_id"], :name => "cvd_repo_index"

  create_table "content_view_definitions", :force => true do |t|
    t.string   "name"
    t.string   "label",                              :null => false
    t.text     "description"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "composite",       :default => false, :null => false
  end

  add_index "content_view_definitions", ["name", "organization_id"], :name => "index_content_view_definitions_on_name_and_organization_id"
  add_index "content_view_definitions", ["organization_id", "label"], :name => "index_content_view_definitions_on_organization_id_and_label", :unique => true

  create_table "content_view_environments", :force => true do |t|
    t.string   "name"
    t.string   "label",           :null => false
    t.string   "cp_id"
    t.integer  "content_view_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_view_environments", ["content_view_id"], :name => "index_content_view_environments_on_content_view_id"

  create_table "content_view_version_environments", :id => false, :force => true do |t|
    t.integer  "content_view_version_id"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_view_version_environments", ["content_view_version_id", "environment_id"], :name => "cvv_env_index"

  create_table "content_view_versions", :force => true do |t|
    t.integer  "content_view_id"
    t.integer  "version",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_view_versions", ["id", "content_view_id"], :name => "cvv_cv_index"

  create_table "content_views", :force => true do |t|
    t.string   "name"
    t.string   "label",                                         :null => false
    t.text     "description"
    t.integer  "content_view_definition_id"
    t.integer  "organization_id"
    t.boolean  "default",                    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "environment_default_id"
  end

  add_index "content_views", ["content_view_definition_id"], :name => "index_content_views_on_content_view_definition_id"
  add_index "content_views", ["environment_default_id"], :name => "index_content_views_on_environment_default_id"
  add_index "content_views", ["name", "organization_id"], :name => "index_content_views_on_name_and_organization_id"
  add_index "content_views", ["organization_id", "label"], :name => "index_content_views_on_organization_id_and_label", :unique => true
  add_index "content_views", ["organization_id"], :name => "index_content_views_on_organization_id"

  create_table "custom_info", :force => true do |t|
    t.string   "keyname"
    t.string   "value"
    t.integer  "informable_id"
    t.string   "informable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "distributors", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "description"
    t.string   "location"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "distributors", ["environment_id"], :name => "index_distributors_on_environment_id"

  create_table "environment_priors", :id => false, :force => true do |t|
    t.integer "environment_id"
    t.integer "prior_id",       :null => false
  end

  add_index "environment_priors", ["environment_id"], :name => "index_environment_priors_on_environment_id"
  add_index "environment_priors", ["prior_id"], :name => "index_environment_priors_on_prior_id"

  create_table "environment_products", :force => true do |t|
    t.integer "environment_id", :null => false
    t.integer "product_id",     :null => false
  end

  add_index "environment_products", ["environment_id", "product_id"], :name => "index_environment_products_on_environment_id_and_product_id", :unique => true

  create_table "environment_system_groups", :force => true do |t|
    t.integer "environment_id"
    t.integer "system_group_id"
  end

  add_index "environment_system_groups", ["environment_id"], :name => "index_environment_system_groups_on_environment_id"
  add_index "environment_system_groups", ["system_group_id"], :name => "index_environment_system_groups_on_system_group_id"

  create_table "environments", :force => true do |t|
    t.string   "name",                               :null => false
    t.string   "description"
    t.boolean  "library",         :default => false, :null => false
    t.integer  "organization_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",                              :null => false
  end

  add_index "environments", ["label", "organization_id"], :name => "index_environments_on_label_and_organization_id", :unique => true
  add_index "environments", ["name", "organization_id"], :name => "index_environments_on_name_and_organization_id", :unique => true
  add_index "environments", ["organization_id"], :name => "index_environments_on_organization_id"

  create_table "gpg_keys", :force => true do |t|
    t.string   "name",            :null => false
    t.integer  "organization_id", :null => false
    t.text     "content",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gpg_keys", ["organization_id", "name"], :name => "index_gpg_keys_on_organization_id_and_name", :unique => true

  create_table "help_tips", :force => true do |t|
    t.string   "key"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_type"
    t.integer  "organization_id"
  end

  add_index "notices", ["organization_id"], :name => "index_notices_on_organization_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "task_id"
    t.text     "system_info_keys"
  end

  add_index "organizations", ["label"], :name => "index_organizations_on_cp_key", :unique => true
  add_index "organizations", ["name"], :name => "index_organizations_on_name", :unique => true
  add_index "organizations", ["task_id"], :name => "index_organizations_on_task_id"

  create_table "organizations_users", :id => false, :force => true do |t|
    t.integer "organization_id"
    t.integer "user_id"
  end

  add_index "organizations_users", ["organization_id"], :name => "index_organizations_users_on_organization_id"
  add_index "organizations_users", ["user_id"], :name => "index_organizations_users_on_user_id"

  create_table "permission_tags", :force => true do |t|
    t.integer  "permission_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permission_tags", ["permission_id"], :name => "index_permission_tags_on_permission_id"
  add_index "permission_tags", ["tag_id"], :name => "index_permission_tags_on_tag_id"

  create_table "permissions", :force => true do |t|
    t.integer  "role_id"
    t.integer  "resource_type_id"
    t.integer  "organization_id"
    t.boolean  "all_tags",         :default => false
    t.boolean  "all_verbs",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",             :default => ""
    t.string   "description",      :default => ""
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pools", ["cp_id"], :name => "index_pools_on_cp_id"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "cp_id"
    t.integer  "multiplier"
    t.integer  "provider_id",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "products_system_templates", :id => false, :force => true do |t|
    t.integer "system_template_id"
    t.integer "product_id"
  end

  add_index "products_system_templates", ["product_id"], :name => "index_products_system_templates_on_product_id"
  add_index "products_system_templates", ["system_template_id"], :name => "index_products_system_templates_on_system_template_id"

  create_table "providers", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "repository_url"
    t.string   "provider_type"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "environment_product_id",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  add_index "repositories", ["content_view_version_id"], :name => "index_repositories_on_content_view_version_id"
  add_index "repositories", ["cp_label"], :name => "index_repositories_on_cp_label"
  add_index "repositories", ["environment_product_id"], :name => "index_repositories_on_environment_product_id"
  add_index "repositories", ["gpg_key_id"], :name => "index_repositories_on_gpg_key_id"
  add_index "repositories", ["label", "content_view_version_id", "environment_product_id"], :name => "repositories_l_cvvi_epi", :unique => true
  add_index "repositories", ["library_instance_id"], :name => "index_repositories_on_library_instance_id"
  add_index "repositories", ["pulp_id"], :name => "index_repositories_on_pulp_id"

  create_table "resource_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description", :limit => 250
    t.boolean  "locked",                     :default => false
    t.string   "type"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "roles_users", :id => false, :force => true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_favorites", ["user_id"], :name => "index_search_favorites_on_user_id"

  create_table "search_histories", :force => true do |t|
    t.string   "params"
    t.string   "path"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_histories", ["user_id"], :name => "index_search_histories_on_user_id"

  create_table "sync_plans", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "sync_date"
    t.string   "interval"
    t.integer  "organization_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "description"
    t.integer  "max_systems",     :default => -1, :null => false
    t.integer  "organization_id",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_groups", ["name", "organization_id"], :name => "index_system_groups_on_name_and_organization_id", :unique => true
  add_index "system_groups", ["organization_id"], :name => "index_system_groups_on_organization_id"
  add_index "system_groups", ["pulp_id"], :name => "index_system_groups_on_pulp_id"

  create_table "system_system_groups", :force => true do |t|
    t.integer  "system_id"
    t.integer  "system_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_system_groups", ["system_group_id"], :name => "index_system_system_groups_on_system_group_id"
  add_index "system_system_groups", ["system_id"], :name => "index_system_system_groups_on_system_id"

  create_table "system_template_distributions", :force => true do |t|
    t.integer "system_template_id",   :null => false
    t.string  "distribution_pulp_id", :null => false
  end

  add_index "system_template_distributions", ["distribution_pulp_id", "system_template_id"], :name => "index_sys_template_distro_on_pulp_id_template_id", :unique => true
  add_index "system_template_distributions", ["distribution_pulp_id"], :name => "index_system_template_distributions_on_distribution_pulp_id"
  add_index "system_template_distributions", ["system_template_id"], :name => "index_system_template_distributions_on_system_template_id"

  create_table "system_template_pack_groups", :force => true do |t|
    t.integer "system_template_id"
    t.string  "name",               :null => false
  end

  add_index "system_template_pack_groups", ["name", "system_template_id"], :name => "index_sys_template_packs_on_name_template_id", :unique => true
  add_index "system_template_pack_groups", ["system_template_id"], :name => "index_system_template_pack_groups_on_system_template_id"

  create_table "system_template_packages", :force => true do |t|
    t.integer "system_template_id", :null => false
    t.string  "package_name",       :null => false
    t.string  "version"
    t.string  "release"
    t.string  "epoch"
    t.string  "arch"
  end

  add_index "system_template_packages", ["system_template_id", "package_name", "version", "release", "epoch", "arch"], :name => "index_sys_template_packages_on_nvrea_template_id", :unique => true
  add_index "system_template_packages", ["system_template_id"], :name => "index_system_template_packages_on_system_template_id"

  create_table "system_template_pg_categories", :force => true do |t|
    t.integer "system_template_id"
    t.string  "name",               :null => false
  end

  add_index "system_template_pg_categories", ["name", "system_template_id"], :name => "index_sys_template_pg_categories_on_name_template_id", :unique => true
  add_index "system_template_pg_categories", ["system_template_id"], :name => "index_system_template_pg_categories_on_system_template_id"

  create_table "system_template_repositories", :force => true do |t|
    t.integer "system_template_id"
    t.integer "repository_id"
  end

  add_index "system_template_repositories", ["repository_id"], :name => "index_system_template_repositories_on_repository_id"
  add_index "system_template_repositories", ["system_template_id"], :name => "index_system_template_repositories_on_system_template_id"

  create_table "system_templates", :force => true do |t|
    t.integer  "revision"
    t.string   "name"
    t.string   "description"
    t.string   "parameters_json"
    t.integer  "parent_id"
    t.integer  "environment_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_templates", ["environment_id"], :name => "index_system_templates_on_environment_id"
  add_index "system_templates", ["name", "environment_id"], :name => "index_system_templates_on_name_and_environment_id", :unique => true
  add_index "system_templates", ["parent_id"], :name => "index_system_templates_on_parent_id"

  create_table "systems", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "description"
    t.string   "location"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "system_template_id"
    t.string   "type",               :default => "System"
    t.integer  "content_view_id"
  end

  add_index "systems", ["content_view_id"], :name => "index_systems_on_content_view_id"
  add_index "systems", ["environment_id"], :name => "index_systems_on_environment_id"
  add_index "systems", ["system_template_id"], :name => "index_systems_on_system_template_id"

  create_table "task_statuses", :force => true do |t|
    t.string   "type"
    t.integer  "organization_id",                :null => false
    t.string   "uuid",                           :null => false
    t.string   "state"
    t.text     "result"
    t.text     "progress"
    t.datetime "start_time"
    t.datetime "finish_time"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
