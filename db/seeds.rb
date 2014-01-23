# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

require 'util/password'
require 'util/puppet'

# variables which are taken from Puppet
first_user_name = (un = Util::Puppet.config_value("user_name")).blank? ? 'admin' : un
first_org_name = (org = Util::Puppet.config_value("org_name")).blank? ? 'ACME_Corporation' : org

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
::User.current = user_admin = ::User.admin
fail "Foreman admin does not exist" unless user_admin
# create a self role for user_admin, this is normally created during admin creation;
# however, for the initial migrate/seed, it needs to be done manually
user_admin.katello_roles.find_or_create_own_role(user_admin)
user_admin.katello_roles << superadmin_role unless user_admin.katello_roles.include?(superadmin_role)
user_admin.remote_id = first_user_name
user_admin.save!
fail "Unable to update admin user: #{format_errors(user_admin)}" if user_admin.errors.size > 0

unless hidden_user = ::User.hidden.first
  ::User.current = ::User.admin
  login = "hidden-#{Password.generate_random_string(6)}"
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
fail "Are you sure you cleared candlepin?! Unable to create first org!" if first_org.environments.nil?

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
