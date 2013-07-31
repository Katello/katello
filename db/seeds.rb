# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

require 'katello'
require 'util/password'
require 'util/puppet'

# variables which are taken from Puppet
first_user_name = (un = Util::Puppet.config_value("user_name")).blank? ? 'admin' : un
first_user_password = (pw = Util::Puppet.config_value("user_pass")).blank? ? 'admin' : pw
first_user_email= (em = Util::Puppet.config_value("user_email")).blank? ? 'root@localhost' : em
first_org_name = (org = Util::Puppet.config_value("org_name")).blank? ? 'ACME_Corporation' : org
first_org_label = (lbl = Util::Puppet.config_value("org_label")).blank? ? 'ACME_Corporation' : lbl

def format_errors model=nil
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

# create basic roles
superadmin_role = Katello::Role.make_super_admin_role

# create read *everything* role and assign permissions to it
#reader_role = Katello::Role.make_readonly_role('Read Everything')
#raise "Unable to create reader role: #{format_errors reader_role}" if reader_role.nil? || reader_role.errors.size > 0
#reader_role.update_attributes(:locked => true)

# obtain an auth source for the users
src = ::AuthSourceInternal.find_or_create_by_type "AuthSourceInternal"
src.update_attribute :name, "Internal"

# TODO: ENGINIFY: the seed will need to be updated to support headpin (e.g. shouldn't need set_pulp_user & foreman)
# create the super admin if none exist - it must be created before any statement in the seed.rb script
user_admin = ::User.find_by_login(first_user_name)
if user_admin
  if user_admin.remote_id.nil?
    user_admin.remote_id = first_user_name
    ::User.current = user_admin
    user_admin.set_pulp_user
    user_admin.save!
  end
else
  ::User.current = user_admin
  user_admin   = ::User.new(
      :roles     => [superadmin_role],
      :login     => first_user_name,
      :password  => first_user_password,
      :mail      => first_user_email,
      :remote_id => first_user_name,
      :auth_source_id => src.id)
  ::User.current = user_admin
  user_admin.save_without_auditing
end
raise "Unable to create admin user: #{format_errors user_admin}" if user_admin.nil? or user_admin.errors.size > 0

unless hidden_user = ::User.hidden.first
  login = "hidden-#{Password.generate_random_string(6)}"
  ::User.current = user_admin
  hidden_user = ::User.new(
    :roles    => [],
    :login    => login,
    :password => Password.generate_random_string(25),
    :mail     => "#{Password.generate_random_string(10)}@localhost",
    :hidden   => true,
    :remote_id => login,
    :auth_source_id => src.id)
  hidden_user.save_without_auditing
end
raise "Unable to create hidden user: #{format_errors hidden_user}" if hidden_user.nil? or hidden_user.errors.size > 0

first_org_desc = first_org_name + " Organization"
first_org_label = first_org_name.gsub(' ', '_')
# create the default org = "admin" if none exist
first_org = Katello::Organization.find_or_create_by_name(:name => first_org_name, :label => first_org_label, :description => first_org_desc, :label => first_org_label)
raise "Unable to create first org: #{format_errors first_org}" if first_org and first_org.errors.size > 0
raise "Are you sure you cleared candlepin?! Unable to create first org!" if first_org.environments.nil?

#create a provider
if Katello::Provider.count == 0
  porkchop = Katello::Provider.create!({
      :name => 'Custom Provider 1',
      :organization => first_org,
      :repository_url => 'http://download.fedoraproject.org/pub/fedora/linux/releases/',
      :provider_type => Katello::Provider::CUSTOM
  })

  Katello::Provider.create!({
      :name => 'Red Hat',
      :organization => first_org,
      :repository_url => 'https://somehost.example.com/content/',
      :provider_type => Katello::Provider::REDHAT
  })
end

if Katello.config.use_pulp
  Katello::Repository.ensure_sync_notification
end
