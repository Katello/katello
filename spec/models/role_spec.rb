#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
describe Role do

  include OrganizationHelperMethods
  include OrchestrationHelper
  include AuthorizationHelperMethods

  before do
    user = users(:admin)
    user.remote_id = 'admin'
    User.current = user
    disable_user_orchestration
    disable_org_orchestration
  end

  describe "role in valid state should be valid" do
    specify { Role.new(:name => "aaaaa").must_be :valid? }
  end

 describe "test read only" do
   let(:organization) {Organization.create!(:name=>"test_org", :label =>"my_key")}
   let(:role) { Role.make_readonly_role("name", organization)}
   let(:global_role) { Role.make_readonly_role("global-name")}
   let(:admin_role) { Role.make_super_admin_role}
   let(:user) {
     disable_user_orchestration
     User.find_or_create_by_login!(
         :login => 'fooo100',
         :password => "password",
         :mail => 'fooo@somewhere.com',
         :auth_source => auth_sources(:one),
         :katello_roles => [ role ])
   }
   let(:global_user) {
     disable_user_orchestration
     User.find_or_create_by_login!(
         :login => 'global_user',
         :password => "password",
         :mail => 'global_user@somewhere.com',
         :auth_source => auth_sources(:one),
         :katello_roles => [ global_role ])
   }
   let(:admin_user) {
     disable_user_orchestration
     User.find_or_create_by_login!(
         :login => 'admin_user_1',
         :password => "password",
         :mail => 'admin_user@somewhere.com',
         :auth_source => auth_sources(:one),
         :katello_roles => [ admin_role ])
   }

   describe "Check the orgs" do
     specify{user.allowed_to_in_katello?(:read, :organizations).must_equal(false) }
     specify{global_user.allowed_to_in_katello?(:read, :organizations).must_equal(true) }

     specify{user.allowed_to_in_katello?(:read, :organizations, nil, organization).must_equal(true)}
     specify{global_user.allowed_to_in_katello?(:read, :organizations, nil, organization).must_equal(true)}

     specify{user.allowed_to_in_katello?(:create, :organizations).must_equal(false)}
     specify{global_user.allowed_to_in_katello?(:create, :organizations).must_equal(false)}
     specify{user.allowed_to_in_katello?(:update, :organizations).must_equal(false)}

     specify {
       User.current = user
       Organization.all_editable?().must_equal(false)
     }
     specify {
       User.current = global_user
       Organization.all_editable?().must_equal(false)
     }
     specify {
       User.current = admin_user
       Organization.all_editable?().must_equal(true)
     }
   end

   describe "Check the envs(katello)" do
     let(:environment){create_environment(:name=>"my_env", :label=> "my_env", :organization => organization, :prior => organization.library)}
     KTEnvironment.read_verbs.each do |verb|
       specify{user.allowed_to_in_katello?(verb, :environments,environment.id,organization).must_equal(true)}
       specify{user.allowed_to_in_katello?(verb, :environments).must_equal(false)}
       specify{global_user.allowed_to_in_katello?(verb, :environments).must_equal(true)}
     end
     specify{user.allowed_to_in_katello?("update_systems", :environments,environment.id,organization).must_equal(false)}
     specify{global_user.allowed_to_in_katello?("update_systems", :environments,environment.id,organization).must_equal(false)}
   end
 end

 describe "Admin permission should be recreated if role exists" do
   before do
     @admin_role = Role.make_super_admin_role
     @admin_role.update_attributes(:locked=>false)
     @admin_role.permissions.destroy_all
     @admin_role.update_attributes(:locked=>true)
   end

   describe "recreating permission" do
     specify {
       @admin_role.permissions.size.must_equal(0)
       @admin_role  = Role.make_super_admin_role
       @admin_role.permissions.size.must_equal(1)
     }
   end

 end

 describe "read ldap roles" do
   before do
     Katello.config[:ldap_roles] = true
     Katello.config[:validate_ldap] = false
   end
   after do
     Katello.config[:ldap_roles] = false
     Katello.config[:validate_ldap] = false
   end
   let(:organization) {Organization.create!(:name=>"test_org", :label =>"my_key")}
   let(:role) { Role.make_readonly_role("name", organization)}
   let(:ldap_role) { Role.make_readonly_role("ldap_role", organization)}
   describe "setting roles on login" do
     specify {
      disable_user_orchestration
       user = User.find_or_create_by_login!(
           :login => 'ldapman5000',
           :password => "password",
           :mail => 'fooo@somewhere.com',
           :auth_source => auth_sources(:one),
           :katello_roles => [ role ])
       LdapGroupRole.create!(:ldap_group => "ldap_group", :role => ldap_role)
       # make ldap groups return the correct thing
       Ldap.stubs(:ldap_groups).returns(['ldap_group'])
       user.roles.include?(ldap_role).must_equal(false)
       user.set_ldap_roles
       # reload the user object from the db
       user = User.find_by_login("ldapman5000")
       # ensure the user got the correct ldap role
       user.katello_roles.include?(ldap_role).must_equal(true)
       # ensure the user still has his original roles, role + login
       user.katello_roles.include?(role).must_equal(true)
       (user.katello_roles.size == 3).must_equal(true)
     }
   end

   describe "verify ldap roles for a normal user" do
     specify {
       disable_user_orchestration
       user = User.find_or_create_by_login!(
           :login => 'ldapman5000',
           :password => "password",
           :mail => 'fooo@somewhere.com',
           :auth_source => auth_sources(:one),
           :katello_roles => [ role ])
       LdapGroupRole.create!(:ldap_group => "ldap_group", :role => ldap_role)
       # make ldap groups return the correct thing
       Ldap.stubs(:ldap_groups).returns(['ldap_group'])
       user.set_ldap_roles
       # not sure if reloading the user like this is necessary
       user = User.find_by_login('ldapman5000')
       user.katello_roles.include?(ldap_role).must_equal(true)
       (user.katello_roles.size == 3).must_equal(true)
       # ldap server hax
       Ldap.stubs(:is_in_groups).returns(true)
       Ldap.stubs(:ldap_groups).returns(['ldap_group'])
       user.verify_ldap_roles
       # make sure we didnt survive the hax
       user = User.find_by_login('ldapman5000')
       user.katello_roles.include?(ldap_role).must_equal(true)
       (user.katello_roles.size == 3).must_equal(true)
     }
   end

   describe "verify ldap roles for a changed user" do
     specify {
       disable_user_orchestration
       user = User.find_or_create_by_login!(
           :login => 'ldapman5000',
           :password => "password",
           :mail => 'fooo@somewhere.com',
           :auth_source => auth_sources(:one),
           :katello_roles => [ role ])
       LdapGroupRole.create!(:ldap_group => "ldap_group", :role => ldap_role)
       # make ldap groups return the correct thing
       Ldap.stubs(:ldap_groups).returns(['ldap_group'])
       user.set_ldap_roles
       # not sure if reloading the user like this is necessary
       user = User.find_by_login('ldapman5000')
       user.katello_roles.include?(ldap_role).must_equal(true)
       # ldap server hax
       Ldap.stubs(:is_in_groups).returns(false)
       Ldap.stubs(:ldap_groups).returns(['ldapppp_group'])
       user.verify_ldap_roles
       # make sure we didnt survive the hax
       user = User.find_by_login('ldapman5000')
       user.katello_roles.include?(ldap_role).must_equal(false)
     }
   end
  end

 describe "checking locked roles" do
   describe "create check" do
     let(:role) {Role.create!(:name => "locked_role",:locked => true)}
     specify do
       lambda{Permission.create!(:name => "Foo", :role=>role, :all_types => true)}.must_raise(ActiveRecord::RecordInvalid)
     end
   end

   describe "update check" do
     let(:role) do
        r = Role.create!(:name => "role")
        Permission.create!(:name => "Foo", :role=>r, :all_types => true)
        r.update_attributes!(:locked => true)
        r
     end
     let(:user) do
       disable_user_orchestration
       User.find_or_create_by_login!(
           :login => 'fooo100',
           :password => "password",
           :mail => 'fooo@somewhere.com',
           :auth_source => auth_sources(:one)
           )
     end
     specify do
       lambda{role.permissions.first.update_attributes!(:all_verbs=>true)}.must_raise(ActiveRecord::RecordInvalid)
     end
     specify do
       lambda{role.permissions.first.destroy}.must_raise(ActiveRecord::ReadOnlyRecord)
     end
     specify do
        lambda{role.update_attributes!(:name=>"boo")}.must_raise(ActiveRecord::RecordInvalid)
     end
     specify do
        lambda{role.update_attributes!(:description=>"description")}.must_raise(ActiveRecord::RecordInvalid)
     end
     specify do
        lambda{role.update_attributes!(:users=>[user])}
     end
   end

 end

end
end
