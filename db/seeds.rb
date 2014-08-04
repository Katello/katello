# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

require 'util/password'

def format_errors(model = nil)
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

::User.current = ::User.anonymous_api_admin

unless hidden_user = ::User.hidden.first
  login = "hidden-#{Password.generate_random_string(6)}".downcase
  hidden_user = ::User.new(:auth_source_id => AuthSourceInternal.first.id,
                           :login => login,
                           :password => Password.generate_random_string(25),
                           :mail => "#{Password.generate_random_string(10)}@localhost",
                           :remote_id => login,
                           :hidden => true)
  hidden_user.save!
  fail "Unable to create hidden user: #{format_errors hidden_user}" if hidden_user.nil? || hidden_user.errors.size > 0
end

if Katello.config.use_pulp
  Katello::Repository.ensure_sync_notification
end

ConfigTemplate.where(:name => "Katello Kickstart Default").first_or_create!(
    :template_kind_id    => TemplateKind.find_by_name('provision').id,
    :operatingsystem_ids => Operatingsystem.where("name not like ? and type = ?", "Red Hat Enterprise Linux", "Redhat").map(&:id),
    :template            => File.read("#{Katello::Engine.root}/app/views/foreman/unattended/kickstart-katello.erb"))

ConfigTemplate.where(:name => "Katello Kickstart Default for RHEL").first_or_create!(
    :template_kind_id    => TemplateKind.find_by_name('provision').id,
    :operatingsystem_ids => Redhat.where("name like ?", "Red Hat Enterprise Linux").map(&:id),
    :template            => File.read("#{Katello::Engine.root}/app/views/foreman/unattended/kickstart-katello_rhel.erb"))

ConfigTemplate.where(:name => "Katello Kickstart default user data").first_or_create!(
    :template_kind_id    => TemplateKind.find_by_name('user_data').id,
    :operatingsystem_ids => Operatingsystem.where("name not like ? and type = ?", "Red Hat Enterprise Linux", "Redhat").map(&:id),
    :template            => File.read("#{Katello::Engine.root}/app/views/foreman/unattended/userdata-katello.erb"))

ConfigTemplate.where(:name => "Katello Kickstart default finish").first_or_create!(
    :template_kind_id    => TemplateKind.find_by_name('finish').id,
    :operatingsystem_ids => Operatingsystem.where("name not like ? and type = ?", "Red Hat Enterprise Linux", "Redhat").map(&:id),
    :template            => File.read("#{Katello::Engine.root}/app/views/foreman/unattended/finish-katello.erb"))

ConfigTemplate.where(:name => "subscription_manager_registration").first_or_create!(
    :snippet  => true,
    :template => File.read("#{Katello::Engine.root}/app/views/foreman/unattended/snippets/_subscription_manager_registration.erb"))

Katello::Util::Search.backend_search_classes.each{|c| c.create_index}

# Proxy features
feature = Feature.find_or_create_by_name('Pulp')
if feature.nil? || feature.errors.any?
  fail "Unable to create proxy feature: #{format_errors feature}"
end

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
  %w(Organization delete_manifest),
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

Setting.find_by_name("dynflow_enable_console").update_attributes!(:value => true) if Rails.env.development?

["Pulp", "Pulp Node"].each do |input|
  f = Feature.find_or_create_by_name(input)
  fail "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
end
