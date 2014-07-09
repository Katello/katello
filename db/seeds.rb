# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

require 'util/password'

# Can be specified via the command line using:
# rake db:seed SEED_INITIAL_ORGANIZATION=MyOrg SEED_INITIAL_LOCATION=MyDefault
first_org_name = ENV['SEED_INITIAL_ORGANIZATION'] || 'Default_Organization'
first_location_name = ENV['SEED_INITIAL_LOCATION'] || 'Default_Location'

def format_errors(model = nil)
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

# create basic roles
superadmin_role = Katello::Role.make_super_admin_role

# create read *everything* role and assign permissions to it
reader_role = Katello::Role.make_readonly_role('Read Everything')
fail "Unable to create reader role: #{format_errors reader_role}" if reader_role.nil? || reader_role.errors.size > 0
reader_role.update_attributes(:locked => true)

# update the Foreman 'admin' to be Katello super admin
::User.current = user_admin = ::User.anonymous_api_admin
fail "Foreman admin does not exist" unless user_admin
# create a self role for user_admin, this is normally created during admin creation;
# however, for the initial migrate/seed, it needs to be done manually
user_admin.katello_roles.find_or_create_own_role(user_admin)
user_admin.katello_roles << superadmin_role unless user_admin.katello_roles.include?(superadmin_role)
user_admin.save!
fail "Unable to update admin user: #{format_errors(user_admin)}" if user_admin.errors.size > 0

unless hidden_user = ::User.hidden.first
  ::User.current = ::User.anonymous_api_admin
  login = "hidden-#{Password.generate_random_string(6)}".downcase
  hidden_user = ::User.new(:auth_source_id => AuthSourceInternal.first.id,
                           :login => login,
                           :password => Password.generate_random_string(25),
                           :mail => "#{Password.generate_random_string(10)}@localhost",
                           :remote_id => login,
                           :hidden => true,
                           :katello_roles => [])
  hidden_user.save!
  fail "Unable to create hidden user: #{format_errors hidden_user}" if hidden_user.nil? || hidden_user.errors.size > 0
end

first_org_desc = first_org_name + " Organization"
first_org_label = first_org_name.gsub(' ', '_')
# create the default org = "admin" if none exist
first_org = Organization.find_or_create_by_name(:name => first_org_name, :label => first_org_label, :description => first_org_desc)
fail "Unable to create first org: #{format_errors first_org}" if first_org && first_org.errors.size > 0
fail "Are you sure you cleared candlepin?! Unable to create first org!" if first_org.kt_environments.nil?

# Create an Initial Location.
# This is a global location for the satelite server by default
location = Location.find_or_create_by_name(:name => first_location_name)
location.update_attributes!(:katello_default => true) unless Location.default_location

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
  %w('Katello::ActivationKey' 'view_activation_keys'),
  %w('Katello::ActivationKey' 'create_activation_keys'),
  %w('Katello::ActivationKey' 'edit_activation_keys'),
  %w('Katello::ActivationKey' 'destroy_activation_keys'),
  %w('SmartProxy' 'manage_capsule_content'),
  %w('Katello::System' 'view_content_hosts'),
  %w('Katello::System' 'create_content_hosts'),
  %w('Katello::System' 'edit_content_hosts'),
  %w('Katello::System' 'destroy_content_hosts'),
  %w('Katello::ContentView' 'view_content_views'),
  %w('Katello::ContentView' 'create_content_views'),
  %w('Katello::ContentView' 'edit_content_views'),
  %w('Katello::ContentView' 'destroy_content_views'),
  %w('Katello::ContentView' 'publish_content_views'),
  %w('Katello::ContentView' 'promote_or_remove_content_views'),
  %w('Katello::GpgKey' 'view_gpg_keys'),
  %w('Katello::GpgKey' 'create_gpg_keys'),
  %w('Katello::GpgKey' 'edit_gpg_keys'),
  %w('Katello::GpgKey' 'destroy_gpg_keys'),
  %w('Katello::HostCollection' 'view_host_collections'),
  %w('Katello::HostCollection' 'create_host_collections'),
  %w('Katello::HostCollection' 'edit_host_collections'),
  %w('Katello::HostCollection' 'destroy_host_collections'),
  %w('Katello::KTEnvironment' 'view_lifecycle_environments'),
  %w('Katello::KTEnvironment' 'create_lifecycle_environments'),
  %w('Katello::KTEnvironment' 'edit_lifecycle_environments'),
  %w('Katello::KTEnvironment' 'destroy_lifecycle_environments'),
  %w('Katello::KTEnvironment' 'promote_or_remove_content_views_to_environments'),
  %w('Katello::Product' 'view_products'),
  %w('Katello::Product' 'create_products'),
  %w('Katello::Product' 'edit_products'),
  %w('Katello::Product' 'destroy_products'),
  %w('Katello::Product' 'sync_products'),
  %w('Katello::SyncPlan' 'view_sync_plans'),
  %w('Katello::SyncPlan' 'create_sync_plans'),
  %w('Katello::SyncPlan' 'edit_sync_plans'),
  %w('Katello::SyncPlan' 'destroy_sync_plans'),
  %w('Organization' 'view_subscriptions'),
  %w('Organization' 'attach_subscriptions'),
  %w('Organization' 'unattach_subscriptions'),
  %w('Organization' 'import_manifest'),
  %w('Organization' 'delete_manifest'),
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
