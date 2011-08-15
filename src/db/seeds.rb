# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require 'util/password'

AppConfig.use_cp = false if ENV['NO_CP']
AppConfig.use_pulp = false if ENV['NO_PULP']

# create basic roles
superadmin_role = Role.find_or_create_by_name(
  :name => 'Administrator', 
  :description => 'Super administrator with all access.')

superadmin_role.allow([], :all)


anonymous_role = Role.find_or_create_by_name(
  :name => 'Anonymous',
  :description => 'Used when user is not logged in. No permissions except reading notifications. Not to be used by regular users.')
reader_role = Role.find_or_create_by_name(
  :name => 'Read Everything',
  :description => 'Permissions to read everything.')

# create the super admin if none exist - it must be created before any statement in the seed.rb script
User.current = user_admin = User.find_or_create_by_username(
  :roles => [ superadmin_role ],
  :username => 'admin',
  :password => 'admin')

# "nobody" user (do not change his name 'anonymous')
user_anonymous = User.find_or_create_by_username(
  :roles => [ anonymous_role ],
  :username => 'anonymous',
  :password => Password.generate_random_string(16),
  :disabled => true)

# candlepin_role for RHSM
candlepin_role = Role.find_or_create_by_name(
  :name => 'Candlepin',
  :description => 'Special role for RHSM. Not to be used by regular users.')
throw "Unable to create candlepin_role: #{candlepin_role.errors}" if candlepin_role and candlepin_role.errors.size > 0

# create the default org = "admin" if none exist
first_org = Organization.find_or_create_by_name(:name => "ACME_Corporation", :description => "ACME Corporation Organization", :cp_key => 'ACME_Corporation')

throw "Unable to create first org: #{first_org.errors}" if first_org and first_org.errors.size > 0
throw "Are you sure you cleared candlepin! unable to create first org!" if first_org.environments.nil?

#create a provider
if Provider.count == 0
  porkchop = Provider.create!({
      :name => 'porkchop',
      :organization => first_org,
      :repository_url => 'http://download.fedoraproject.org/pub/fedora/linux/releases/',
      :provider_type => Provider::CUSTOM
  })

  Provider.create!({
      :name => 'redhat',
      :organization => first_org,
      :repository_url => 'https://somehost.example.com/content/',
      :provider_type => Provider::REDHAT
  })
end
