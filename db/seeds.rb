# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

def format_errors(model = nil)
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

if ENV['SEED_ORGANIZATION']
  Organization.without_auditing do
    User.current = User.anonymous_admin
    org = Organization.find_by!(:name => ENV['SEED_ORGANIZATION'])
    ForemanTasks.sync_task(::Actions::Katello::Organization::Create, org) unless org.library
    User.current = nil
  end
  if Setting['db_pending_seed']
    admin = User.where(:login => ENV['SEED_ADMIN_USER'].present? ? ENV['SEED_ADMIN_USER'] : 'admin').first
    if admin && admin.default_organization.nil?
      admin.default_organization = Organization.find_by!(:name => ENV['SEED_ORGANIZATION'])
      admin.save!
    end
  end
end

::User.current = ::User.anonymous_api_admin

if SETTINGS[:katello][:use_pulp]
  Katello::Repository.ensure_sync_notification
end

# Provisioning Templates

kinds = [:provision, :finish, :user_data].inject({}) do |hash, kind|
  hash[kind] = TemplateKind.find_by!(:name => kind)
  hash
end

defaults = {:vendor => "Katello", :default => true, :locked => true}

templates = [{:name => "Katello Kickstart Default",           :source => "kickstart-katello.erb",      :template_kind => kinds[:provision]},
             {:name => "Katello Kickstart Default User Data", :source => "userdata-katello.erb",       :template_kind => kinds[:user_data]},
             {:name => "Katello Kickstart Default Finish",    :source => "finish-katello.erb",         :template_kind => kinds[:finish]},
             {:name => "subscription_manager_registration",   :source => "snippets/_subscription_manager_registration.erb", :snippet => true}]

templates.each do |template|
  template[:template] = File.read(File.join(Katello::Engine.root, "app/views/foreman/unattended", template.delete(:source)))
  pt = ProvisioningTemplate.find_or_create_by(:name => template["name"])
  defaults.merge(template).each do |k, v|
    if k == :template_kind
      pt.template_kind = v
      next
    end
    pt[k] = v
  end
  pt.save!
end

# Ensure all default templates are seeded into the first org and loc
ProvisioningTemplate.where(:default => true).each do |template|
  template.organizations << Organization.first unless template.organizations.include?(Organization.first) || Organization.count.zero?
  template.locations << Location.first unless template.locations.include?(Location.first) || Location.count.zero?
end

# Proxy features
feature = Feature.find_or_create_by(:name => 'Pulp')
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
  %w(Organization delete_manifest)
]

permissions.each do |resource, permission|
  Permission.find_or_create_by(:resource_type => resource, :name => permission)
end

default_permissions = {
  :Viewer => [:view_activation_keys, :view_content_hosts, :view_content_views, :view_gpg_keys, :view_host_collections,
              :view_lifecycle_environments, :view_products, :view_subscriptions, :view_sync_plans]
}

Role.without_auditing do
  default_permissions.each do |role_name, permission_names|
    permissions = Permission.where(:name => permission_names).to_a
    create_filters(Role.find_by!(:name => role_name), permissions)
  end
end

Setting.find_by!(:name => "dynflow_enable_console").update_attributes!(:value => true) if Rails.env.development?

["Pulp", "Pulp Node"].each do |input|
  f = Feature.find_or_create_by(:name => input)
  fail "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
end

# Mail Notifications
notifications = [
  {:name              => :katello_host_advisory,
   :description       => N_('A summary of available and applicable errata for your hosts'),
   :mailer            => 'Katello::ErrataMailer',
   :method            => 'host_errata',
   :subscription_type => 'report'
  },

  {:name              => :katello_sync_errata,
   :description       => N_('A summary of new errata after a repository is synchronized'),
   :mailer            => 'Katello::ErrataMailer',
   :method            => 'sync_errata',
   :subscription_type => 'alert'
  },

  {:name              => :katello_promote_errata,
   :description       => N_('A post-promotion summary of hosts with installable errata'),
   :mailer            => 'Katello::ErrataMailer',
   :method            => 'promote_errata',
   :subscription_type => 'alert'
  }
]

notifications.each do |notification|
  ::MailNotification.find_or_create_by(:name => notification[:name],
                                       :description => notification[:description],
                                       :mailer => notification[:mailer],
                                       :method => notification[:method],
                                       :subscription_type => notification[:subscription_type])
end
