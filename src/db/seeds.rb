# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# create the super admin if none exist - it must be created before any statement in the seed.rb script
User.current = user_admin = User.find_or_create_by_username(:username => 'admin', :password => 'password123')

# "nobody" user
user_anonymous = User.find_or_create_by_username(:username => 'anonymous', :password => 'password123')

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

# configure limited permissions for the anonymous user
Role.allow 'anonymous_role', [:create, :update], :ar_notices
Role.allow 'anonymous_role', [:create, :update], :ar_user_notices

# configure permissions for the super admin
Role.allow 'admin_role', { :sync_management => [:read, :delete, :sync] }
Role.allow 'admin_role', { :sync_schedules =>  [:read, :apply] }
Role.allow 'admin_role', { :sync_plans =>      [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :dashboard =>       [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :content =>         [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :systems =>         [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :operations =>      [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :products =>        [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :owners =>          [:create, :read, :update, :delete, :import] }
Role.allow 'admin_role', { :consumers =>       [:create, :read, :update, :delete,
                                                :export, :re_register] }
Role.allow 'admin_role', { :entitlements =>    [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :certificates =>    [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :pools =>           [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :users =>           [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :roles =>           [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :nodes =>           [:read] }
Role.allow 'admin_role', { :puppetclasses =>   [:read] }
Role.allow 'admin_role', { :providers =>       [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :repositories =>    [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :search =>          [:create, :read, :delete] }
Role.allow 'admin_role', { :environments =>    [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :lockers =>         [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :organizations =>   [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :changesets =>      [:create, :read, :update, :delete, :promote] }

Role.allow 'admin_role', { :promotions =>      [:read] }
Role.allow 'admin_role', { :user_sessions =>   [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :accounts =>        [:create, :read, :update, :delete] }
Role.allow 'admin_role', { :jammit =>          [:package] }
Role.allow 'admin_role', { :notices =>         [:read, :delete] }

# TODO protection of all /api controllers (currently all roles authorized by default)
#Role.allow 'admin_role', { :"api/xxx" => [:read] }

Role.allow 'admin_role', { :packages =>        [:read]}
Role.allow 'admin_role', { :errata =>          [:read]}


# ActiveRecord protection - allow admin_role all actions for all models
ActiveRecord::Base.connection.tables.each do |t|
  Role.allow 'admin_role', [:create, :update, :delete], "ar_#{t}"
end

# candlepin_role permissions for RHSM
[:systems].each { |t| Role.allow 'candlepin_role', [:create, :update, :delete], "ar_#{t}" }
