# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# create the super admin if none exist - it must be created before any statement in the seed.rb script
User.current = user_admin = User.find_or_create_by_username(:username => 'admin', :password => 'admin')

# "nobody" user
user_anonymous = User.find_or_create_by_username(:username => 'anonymous', :password => 'admin')

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

# ActiveRecord protection - allow admin_role all actions for all models
ActiveRecord::Base.connection.tables.each do |t|
  Role.allow 'admin_role', [:create, :update, :delete, :read], "#{t}"
end


# configure limited permissions for the anonymous user
Role.allow 'anonymous_role', [:create, :update], :notices
Role.allow 'anonymous_role', [:create, :update], :user_notices


# TODO protection of all /api controllers (currently all roles authorized by default)
#Role.allow 'admin_role', { :"api/xxx" => [:read] }

#These have associated models, but have extra actions
Role.allow 'admin_role', [:promote], "changesets"

#These do not have associated models
Role.allow 'admin_role', [:read], "dashboard"
Role.allow 'admin_role', [:read], "promotions"
Role.allow 'admin_role', [:read, :delete, :sync], "sync_management"
Role.allow 'admin_role', [:read], "packages"
Role.allow 'admin_role', [:read], "errata"
Role.allow 'admin_role', [:create, :delete, :read], "search"
Role.allow 'admin_role', [:read], "operations"
Role.allow 'admin_role', [:create, :read, :update, :delete], "repositories"
Role.allow 'admin_role', [:read, :apply], "sync_schedules"

#These are candlepin proxy actions
Role.allow 'admin_role', [:create, :read, :update, :delete, :import], "owners"
Role.allow 'admin_role', [:create, :read, :update, :delete], "entitlements"
Role.allow 'admin_role', [:create, :read, :update, :delete], "pools"
Role.allow 'admin_role', [:create, :read, :update, :delete], "certificates"
Role.allow 'admin_role', [:export, :re_register, :create, :read, :update, :delete], "consumers"


Role.allow 'admin_role', [:package], "jammit"


# candlepin_role permissions for RHSM
[:systems].each { |t| Role.allow 'candlepin_role', [:create, :update, :delete], "#{t}" }
