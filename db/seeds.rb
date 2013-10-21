# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

require 'util/password'
require 'util/puppet'

# variables which are taken from Puppet
first_user_name = (un = Util::Puppet.config_value("user_name")).blank? ? 'admin' : un
first_user_password = (pw = Util::Puppet.config_value("user_pass")).blank? ? 'admin' : pw
first_user_email = (em = Util::Puppet.config_value("user_email")).blank? ? 'root@localhost' : em
first_org_name = (org = Util::Puppet.config_value("org_name")).blank? ? 'ACME_Corporation' : org
first_remote_id = first_user_name.gsub(/[^A-Za-z0-9_-]/, "_")

def format_errors(model = nil)
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

# create basic roles
superadmin_role = Katello::Role.make_super_admin_role

# create read *everything* role and assign permissions to it
reader_role = Katello::Role.make_readonly_role('Read Everything')
raise "Unable to create reader role: #{format_errors reader_role}" if reader_role.nil? || reader_role.errors.size > 0
reader_role.update_attributes(:locked => true)

# update the Foreman 'admin' to be Katello super admin
::User.current = user_admin = ::User.admin
raise "Foreman admin does not exist" unless user_admin
user_admin.update_attributes(:katello_roles => [superadmin_role],:remote_id => first_remote_id)
raise "Unable to update admin user: #{format_errors(user_admin)}" if user_admin.errors.size > 0

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
  raise "Unable to create hidden user: #{format_errors hidden_user}" if hidden_user.nil? || hidden_user.errors.size > 0
end

first_org_desc = first_org_name + " Organization"
first_org_label = first_org_name.gsub(' ', '_')
# create the default org = "admin" if none exist
first_org = Katello::Organization.find_or_create_by_name(:name => first_org_name, :label => first_org_label, :description => first_org_desc)
raise "Unable to create first org: #{format_errors first_org}" if first_org && first_org.errors.size > 0
raise "Are you sure you cleared candlepin?! Unable to create first org!" if first_org.environments.nil?

if Katello.config.use_pulp
  Katello::Repository.ensure_sync_notification
end
