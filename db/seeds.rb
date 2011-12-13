# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

require 'util/password'

AppConfig.use_cp = false if ENV['NO_CP']
AppConfig.use_pulp = false if ENV['NO_PULP']

# create basic roles
superadmin_role = Role.find_or_create_by_name(
  :name => 'Administrator', 
  :description => 'Super administrator with all access.')
throw "Unable to create super-admin role: #{$!}" if superadmin_role.nil? or superadmin_role.errors.size > 0

superadmin_role_perm = Permission.find_or_create_by_name(:name=> "super-admin-perm", :role => superadmin_role, :all_types => true)
throw "Unable to create super-admin role permission: #{$!}" if superadmin_role_perm.nil? or superadmin_role_perm.errors.size > 0

# create read *everything* role and assign permissions to it
reader_role = Role.find_or_create_by_name(
  :name => 'Read Everything',
  :description => 'Permissions to read everything.')
throw "Unable to create reader role: #{$!}" if reader_role.nil? or reader_role.errors.size > 0

reader_role_perm = Permission.find_or_create_by_name(:role => reader_role,
                   :resource_type => ResourceType.find_by_name("all"),
                   :all_tags => true,
                   :all_verbs => true,
                   :name => "Read All",
                   :description => "Read everything permission")
throw "Unable to create reader role permission: #{$!}" if reader_role_perm.nil? or reader_role_perm.errors.size > 0

# create the super admin if none exist - it must be created before any statement in the seed.rb script
User.current = user_admin = User.find_or_create_by_username(
  :roles => [ superadmin_role ],
  :username => 'admin',
  :password => 'admin',
  :email => 'root@localhost')
throw "Unable to create admin user: #{$!}" if user_admin.nil? or user_admin.errors.size > 0

# create the default org = "admin" if none exist
first_org = Organization.find_or_create_by_name(:name => "ACME_Corporation", :description => "ACME Corporation Organization", :cp_key => 'ACME_Corporation')
throw "Unable to create first org: #{first_org.errors}" if first_org and first_org.errors.size > 0
throw "Are you sure you cleared candlepin! unable to create first org!" if first_org.environments.nil?

#create a provider
if Provider.count == 0
  porkchop = Provider.create!({
      :name => 'Custom Provider 1',
      :organization => first_org,
      :repository_url => 'http://download.fedoraproject.org/pub/fedora/linux/releases/',
      :provider_type => Provider::CUSTOM
  })

  Provider.create!({
      :name => 'Red Hat',
      :organization => first_org,
      :repository_url => 'https://somehost.example.com/content/',
      :provider_type => Provider::REDHAT
  })
end
