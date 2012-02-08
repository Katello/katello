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

ActiveRecord::Schema.define(:version => 20120125165742) do

  create_table "activation_keys", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "organization_id",    :null => false
    t.integer  "environment_id",     :null => false
    t.integer  "system_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "activation_keys", ["user_id"], :name => "index_activation_keys_on_user_id"

  create_table "changeset_dependencies", :force => true do |t|
    t.integer "changeset_id"
    t.string  "package_id"
    t.string  "display_name"
    t.integer "product_id",    :null => false
    t.string  "dependency_of"
  end

  create_table "changeset_distributions", :force => true do |t|
    t.integer "changeset_id"
    t.string  "distribution_id"
    t.string  "display_name"
    t.integer "product_id",      :null => false
  end

  create_table "changeset_errata", :force => true do |t|
    t.integer "changeset_id"
    t.string  "errata_id"
    t.string  "display_name"
    t.integer "product_id",   :null => false
  end

  create_table "changeset_packages", :force => true do |t|
    t.integer "changeset_id"
    t.string  "package_id"
    t.string  "display_name"
    t.integer "product_id",   :null => false
  end

  create_table "changeset_users", :force => true do |t|
    t.integer  "changeset_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "changesets", :force => true do |t|
    t.integer  "environment_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "promotion_date"
    t.string   "state",          :default => "new", :null => false
    t.integer  "task_status_id"
    t.string   "description"
  end

  create_table "changesets_products", :id => false, :force => true do |t|
    t.integer "changeset_id"
    t.integer "product_id"
  end

  create_table "changesets_repositories", :id => false, :force => true do |t|
    t.integer "changeset_id",  :null => false
    t.integer "repository_id", :null => false
  end

  create_table "changesets_system_templates", :id => false, :force => true do |t|
    t.integer "changeset_id",       :null => false
    t.integer "system_template_id", :null => false
  end

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

  create_table "environment_priors", :id => false, :force => true do |t|
    t.integer "environment_id"
    t.integer "prior_id",       :null => false
  end

  create_table "environment_products", :force => true do |t|
    t.integer "environment_id", :null => false
    t.integer "product_id",     :null => false
  end

  add_index "environment_products", ["environment_id", "product_id"], :name => "index_environment_products_on_environment_id_and_product_id", :unique => true

  create_table "environments", :force => true do |t|
    t.string   "name",                               :null => false
    t.string   "description"
    t.boolean  "library",         :default => false, :null => false
    t.integer  "organization_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filters", :force => true do |t|
    t.string   "pulp_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filters_products", :id => false, :force => true do |t|
    t.integer "filter_id"
    t.integer "product_id"
  end

  create_table "filters_repositories", :id => false, :force => true do |t|
    t.integer "filter_id"
    t.integer "repository_id"
  end

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

  create_table "key_pools", :force => true do |t|
    t.integer "activation_key_id"
    t.integer "pool_id"
    t.integer "allocated",         :default => 0, :null => false
  end

  create_table "marketing_engineering_products", :force => true do |t|
    t.integer "marketing_product_id"
    t.integer "engineering_product_id"
  end

  add_index "marketing_engineering_products", ["engineering_product_id"], :name => "index_marketing_engineering_products_on_engineering_product_id"
  add_index "marketing_engineering_products", ["marketing_product_id"], :name => "index_marketing_engineering_products_on_marketing_product_id"

  create_table "notices", :force => true do |t|
    t.string   "text",         :limit => 1024,                    :null => false
    t.text     "details"
    t.boolean  "global",                       :default => false, :null => false
    t.string   "level",                                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_type"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "cp_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "task_id"
  end

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

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "cp_id"
    t.integer  "multiplier"
    t.integer  "provider_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gpg_key_id"
    t.string   "type"
    t.integer  "sync_plan_id"
  end

  create_table "products_system_templates", :id => false, :force => true do |t|
    t.integer "system_template_id"
    t.integer "product_id"
  end

  create_table "providers", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "repository_url"
    t.string   "provider_type"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repositories", :force => true do |t|
    t.string   "name"
    t.string   "pulp_id",                                  :null => false
    t.boolean  "enabled",                :default => true
    t.integer  "environment_product_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "major"
    t.string   "minor"
    t.integer  "gpg_key_id"
  end

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
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "search_favorites", :force => true do |t|
    t.string   "params"
    t.string   "path"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_histories", :force => true do |t|
    t.string   "params"
    t.string   "path"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sync_plans", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "sync_date"
    t.string   "interval"
    t.integer  "organization_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_activation_keys", :force => true do |t|
    t.integer "system_id"
    t.integer "activation_key_id"
  end

  add_index "system_activation_keys", ["activation_key_id"], :name => "index_system_activation_keys_on_activation_key_id"
  add_index "system_activation_keys", ["system_id"], :name => "index_system_activation_keys_on_system_id"

  create_table "system_tasks", :force => true do |t|
    t.integer "system_id"
    t.integer "task_status_id"
  end

  create_table "system_template_distributions", :force => true do |t|
    t.integer "system_template_id",   :null => false
    t.string  "distribution_pulp_id", :null => false
  end

  add_index "system_template_distributions", ["system_template_id"], :name => "index_system_template_distributions_on_system_template_id"

  create_table "system_template_pack_groups", :force => true do |t|
    t.integer "system_template_id"
    t.string  "name",               :null => false
  end

  add_index "system_template_pack_groups", ["system_template_id"], :name => "index_system_template_pack_groups_on_system_template_id"

  create_table "system_template_packages", :force => true do |t|
    t.integer "system_template_id", :null => false
    t.string  "package_name",       :null => false
    t.string  "version"
    t.string  "release"
    t.string  "epoch"
    t.string  "arch"
  end

  add_index "system_template_packages", ["system_template_id"], :name => "index_system_template_packages_on_system_template_id"

  create_table "system_template_pg_categories", :force => true do |t|
    t.integer "system_template_id"
    t.string  "name",               :null => false
  end

  add_index "system_template_pg_categories", ["system_template_id"], :name => "index_system_template_pg_categories_on_system_template_id"

  create_table "system_template_repositories", :id => false, :force => true do |t|
    t.integer "system_template_id"
    t.integer "repository_id"
  end

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
  end

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
  end

  add_index "task_statuses", ["uuid"], :name => "index_task_statuses_on_uuid"

  create_table "user_notices", :force => true do |t|
    t.integer "user_id"
    t.integer "notice_id"
    t.boolean "viewed",    :default => false, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.boolean  "helptips_enabled",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "own_role_id"
    t.integer  "page_size",              :default => 25,    :null => false
    t.boolean  "disabled",               :default => false
    t.string   "email"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.text     "preferences"
  end

  create_table "verbs", :force => true do |t|
    t.string   "verb"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
