# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# create basic roles
superadmin_role = Role.find_or_create_by_name(:name => 'superadmin_role', :superadmin => true)
anonymous_role = Role.find_or_create_by_name(:name => 'anonymous_role')

# create the super admin if none exist - it must be created before any statement in the seed.rb script
User.current = user_admin = User.find_or_create_by_username(
  :roles => [ superadmin_role ],
  :username => 'admin',
  :password => 'admin')

# "nobody" user
user_anonymous = User.find_or_create_by_username(
  :roles => [ anonymous_role ],
  :username => 'anonymous',
  :password => 'admin')

# candlepin_role for RHSM
candlepin_role = Role.find_or_create_by_name(:name => 'candlepin_role')
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
      :name => 'red hat',
      :organization => first_org,
      :repository_url => 'https://somehost.example.com/content/',
      :provider_type => Provider::REDHAT
  })
end

#JSON(File.read("#{Rails.root}/db/products.json")).collect{|p| p.with_indifferent_access }.each do |p|
#  p = Product.new(p) do |product|
#    product.provider = porkchop
#    product.organization = porkchop.organization
#  end
#  p.save!
#end

# clean all permission and create new default set

Permission.delete_all

# ANONYMOUS ROLE - configure limited permissions
anonymous_role.allow [:create, :update], :notices
anonymous_role.allow [:create, :update], :user_notices

# CANDLEPIN ROLE - for RHSM
[:systems].each { |t| Role.allow 'candlepin_role', [:create, :update, :delete], "#{t}" }

# ADMIN - already allowed to all actions
#Allow for all models
ActiveRecord::Base.connection.tables.each do |t|
  user_admin.allow [:create, :update, :delete, :read], "#{t}"
end

#These have associated models, but have extra actions
user_admin.allow [:promote], "changesets"

#These do not have associated models
user_admin.allow [:read], "dashboard"
user_admin.allow [:read], "promotions"
user_admin.allow [:read, :delete, :sync], "sync_management"
user_admin.allow [:read], "packages"
user_admin.allow [:read], "errata"
user_admin.allow [:create, :delete, :read], "search"
user_admin.allow [:read], "operations"
user_admin.allow [:create, :read, :update, :delete], "repositories"
user_admin.allow [:read, :apply], "sync_schedules"

#These are candlepin proxy actions
user_admin.allow [:create, :read, :update, :delete, :import], "owners"
user_admin.allow [:create, :read, :update, :delete], "entitlements"
user_admin.allow [:create, :read, :update, :delete], "pools"
user_admin.allow [:create, :read, :update, :delete], "certificates"
user_admin.allow [:export, :re_register, :create, :read, :update, :delete], "consumers"

user_admin.allow [:package], "jammit"

# TODO protection of all /api controllers (currently all roles authorized by default)
#user_admin.allow { :"api/xxx" => [:read] }
