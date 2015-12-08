# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#
User.current = ::User.anonymous_api_admin

# Roles and Permissions

permissions = [
  %w(Katello::ActivationKey view_activation_keys),
  %w(Katello::ActivationKey create_activation_keys),
  %w(Katello::ActivationKey edit_activation_keys),
  %w(Katello::ActivationKey destroy_activation_keys),
  %w(SmartProxy manage_capsule_content),
  %w(Katello::System view_content_hosts),
  %w(Katello::System create_content_hosts),
  %w(Katello::System edit_content_hosts),
  %w(Katello::System destroy_content_hosts),
  %w(Katello::ContentView view_content_views),
  %w(Katello::ContentView create_content_views),
  %w(Katello::ContentView edit_content_views),
  %w(Katello::ContentView destroy_content_views),
  %w(Katello::ContentView publish_content_views),
  %w(Katello::ContentView promote_or_remove_content_views),
  %w(Katello::GpgKey view_gpg_keys),
  %w(Katello::GpgKey create_gpg_keys),
  %w(Katello::GpgKey edit_gpg_keys),
  %w(Katello::GpgKey destroy_gpg_keys),
  %w(Katello::HostCollection view_host_collections),
  %w(Katello::HostCollection create_host_collections),
  %w(Katello::HostCollection edit_host_collections),
  %w(Katello::HostCollection destroy_host_collections),
  %w(Katello::KTEnvironment view_lifecycle_environments),
  %w(Katello::KTEnvironment create_lifecycle_environments),
  %w(Katello::KTEnvironment edit_lifecycle_environments),
  %w(Katello::KTEnvironment destroy_lifecycle_environments),
  %w(Katello::KTEnvironment promote_or_remove_content_views_to_environments),
  %w(Katello::Product view_products),
  %w(Katello::Product create_products),
  %w(Katello::Product edit_products),
  %w(Katello::Product destroy_products),
  %w(Katello::Product sync_products),
  %w(Katello::SyncPlan view_sync_plans),
  %w(Katello::SyncPlan create_sync_plans),
  %w(Katello::SyncPlan edit_sync_plans),
  %w(Katello::SyncPlan destroy_sync_plans),
  %w(Organization view_subscriptions),
  %w(Organization attach_subscriptions),
  %w(Organization unattach_subscriptions),
  %w(Organization import_manifest),
  %w(Organization delete_manifest)
]

permissions.each do |resource, permission|
  Permission.find_or_create_by_resource_type_and_name resource, permission
end

default_permissions = {
  :Viewer => [:view_activation_keys, :view_content_hosts, :view_content_views, :view_gpg_keys, :view_host_collections,
              :view_lifecycle_environments, :view_products, :view_subscriptions, :view_sync_plans]
}

Role.without_auditing do
  default_permissions.each do |role_name, permission_names|
    permissions = Permission.find_all_by_name permission_names
    create_filters(Role.find_by_name(role_name), permissions)
  end
end

::User.current = nil
