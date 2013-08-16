#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'
describe Role do
  include OrchestrationHelper
  include AuthorizationHelperMethods

  before do
    disable_user_orchestration
    disable_org_orchestration
  end

  context "role in valid state should be valid" do
    specify { Role.new(:name => "aaaaa").should be_valid }
  end

 context "test read only" do
   let(:organization) {Organization.create!(:name=>"test_org", :label =>"my_key")}
   let(:role) { Role.make_readonly_role("name", organization)}
   let(:global_role) { Role.make_readonly_role("global-name")}
   let(:admin_role) { Role.make_super_admin_role}
   let(:user) {
     User.find_or_create_by_username(
         :username => 'fooo100',
         :password => "password",
         :email => 'fooo@somewhere.com',
         :roles => [ role ])
   }
   let(:global_user) {
     User.find_or_create_by_username(
         :username => 'global_user',
         :password => "password",
         :email => 'global_user@somewhere.com',
         :roles => [ global_role ])
   }
   let(:admin_user) {
     User.find_or_create_by_username(
         :username => 'admin_user',
         :password => "password",
         :email => 'admin_user@somewhere.com',
         :roles => [ admin_role ])
   }

   context "Check the orgs" do
     specify{user.allowed_to?(:read, :organizations).should be_false }
     specify{global_user.allowed_to?(:read, :organizations).should be_true }

     specify{user.allowed_to?(:read, :organizations, nil, organization ).should be_true}
     specify{global_user.allowed_to?(:read, :organizations, nil, organization ).should be_true}

     specify{user.allowed_to?(:create, :organizations).should be_false}
     specify{global_user.allowed_to?(:create, :organizations).should be_false}
     specify{user.allowed_to?(:update, :organizations).should be_false}

     specify {
       User.current = user
       Organization.all_editable?().should be_false
     }
     specify {
       User.current = global_user
       Organization.all_editable?().should be_false
     }
     specify {
       User.current = admin_user
       Organization.all_editable?().should be_true
     }
   end

   context "Check the envs", :katello => true do
     let(:environment){create_environment(:name=>"my_env", :label=> "my_env", :organization => organization, :prior => organization.library)}
     KTEnvironment.read_verbs.each do |verb|
       specify{user.allowed_to?(verb, :environments,environment.id,organization).should be_true}
       specify{user.allowed_to?(verb, :environments).should be_false}
       specify{global_user.allowed_to?(verb, :environments).should be_true}
     end
     specify{user.allowed_to?("update_systems", :environments,environment.id,organization).should be_false}
     specify{global_user.allowed_to?("update_systems", :environments,environment.id,organization).should be_false}
   end
 end

 context "Admin permission should be recreated if role exists" do
   before do
     @admin_role = Role.make_super_admin_role
     @admin_role.update_attributes(:locked=>false)
     @admin_role.permissions.destroy_all
     @admin_role.update_attributes(:locked=>true)
   end

   context "recreating permission" do
     specify {
       @admin_role.permissions.size.should == 0
       @admin_role  = Role.make_super_admin_role
       @admin_role.permissions.size.should == 1
     }
   end

 end

 context "read ldap roles" do
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
   context "setting roles on login" do
     specify {
       user = User.find_or_create_by_username(
           :username => 'ldapman5000',
           :password => "password",
           :email => 'fooo@somewhere.com',
           :roles => [ role ])
       LdapGroupRole.create!(:ldap_group => "ldap_group", :role => ldap_role)
       # make ldap groups return the correct thing
       Ldap.stub(:ldap_groups).and_return(['ldap_group'])
       user.roles.include?(ldap_role).should be_false
       user.set_ldap_roles
       # reload the user object from the db
       user = User.find_by_username("ldapman5000")
       # ensure the user got the correct ldap role
       user.roles.include?(ldap_role).should be_true
       # ensure the user still has his original roles, role + username
       user.roles.include?(role).should be_true
       (user.roles.size == 3).should be_true
     }
   end

   context "verify ldap roles for a normal user" do
     specify {
       user = User.find_or_create_by_username(
           :username => 'ldapman5000',
           :password => "password",
           :email => 'fooo@somewhere.com',
           :roles => [ role ])
       LdapGroupRole.create!(:ldap_group => "ldap_group", :role => ldap_role)
       # make ldap groups return the correct thing
       Ldap.stub(:ldap_groups).and_return(['ldap_group'])
       user.set_ldap_roles
       # not sure if reloading the user like this is necessary
       user = User.find_by_username('ldapman5000')
       user.roles.include?(ldap_role).should be_true
       (user.roles.size == 3).should be_true
       # ldap server hax
       Ldap.stub(:is_in_groups).and_return(true)
       Ldap.stub(:ldap_groups).and_return(['ldap_group'])
       user.verify_ldap_roles
       # make sure we didnt survive the hax
       user = User.find_by_username('ldapman5000')
       user.roles.include?(ldap_role).should be_true
       (user.roles.size == 3).should be_true
     }
   end

   context "verify ldap roles for a changed user" do
     specify {
       user = User.find_or_create_by_username(
           :username => 'ldapman5000',
           :password => "password",
           :email => 'fooo@somewhere.com',
           :roles => [ role ])
       LdapGroupRole.create!(:ldap_group => "ldap_group", :role => ldap_role)
       # make ldap groups return the correct thing
       Ldap.stub(:ldap_groups).and_return(['ldap_group'])
       user.set_ldap_roles
       # not sure if reloading the user like this is necessary
       user = User.find_by_username('ldapman5000')
       user.roles.include?(ldap_role).should be_true
       # ldap server hax
       Ldap.stub(:is_in_groups).and_return(false)
       Ldap.stub(:ldap_groups).and_return(['ldapppp_group'])
       user.verify_ldap_roles
       # make sure we didnt survive the hax
       user = User.find_by_username('ldapman5000')
       user.roles.include?(ldap_role).should be_false
     }
   end
  end

 context "checking locked roles" do
   context "create check" do
     let(:role) {Role.create!(:name => "locked_role",:locked => true)}
     specify do
       lambda{Permission.create!(:name => "Foo", :role=>role, :all_types => true)}.should raise_error(ActiveRecord::RecordInvalid)
     end
   end

   context "update check" do
     let(:role) do
        r = Role.create!(:name => "role")
        Permission.create!(:name => "Foo", :role=>r, :all_types => true)
        r.update_attributes!(:locked => true)
        r
     end
     let(:user) do
       User.find_or_create_by_username(
           :username => 'fooo100',
           :password => "password",
           :email => 'fooo@somewhere.com'
           )
     end
     specify do
       lambda{role.permissions.first.update_attributes!(:all_verbs=>true)}.should raise_error(ActiveRecord::RecordInvalid)
     end
     specify do
       lambda{role.permissions.first.destroy}.should raise_error(ActiveRecord::ReadOnlyRecord)
     end
     specify do
        lambda{role.update_attributes!(:name=>"boo")}.should raise_error(ActiveRecord::RecordInvalid)
     end
     specify do
        lambda{role.update_attributes!(:description=>"description")}.should raise_error(ActiveRecord::RecordInvalid)
     end
     specify do
        lambda{role.update_attributes!(:users=>[user])}.should_not raise_error(ActiveRecord::RecordInvalid)
     end
   end

 end


end
