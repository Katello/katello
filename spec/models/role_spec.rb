#
# Copyright 2011 Red Hat, Inc.
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
describe Permission do
  include OrchestrationHelper
  include AuthorizationHelperMethods

 before do
    disable_user_orchestration
    disable_org_orchestration
 end
 context "test read only" do
   let(:organization) {Organization.create!(:name => "test_org", :cp_key =>"my_key")}
   let(:role) { Role.make_readonly_role("name", organization)}
   let(:global_role) { Role.make_readonly_role("global-name")}
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


   context "Check the orgs" do
     specify{user.allowed_to?(:read, :organizations).should be_false }
     specify{global_user.allowed_to?(:read, :organizations).should be_true }

     specify{user.allowed_to?(:read, :organizations, nil, organization ).should be_true}
     specify{global_user.allowed_to?(:read, :organizations, nil, organization ).should be_true}

     specify{user.allowed_to?(:create, :organizations).should be_false}
     specify{global_user.allowed_to?(:create, :organizations).should be_false}
     specify{user.allowed_to?(:update, :organizations).should be_false}
   end

   context "Check the envs" do
     let(:environment){KTEnvironment.create!(:name =>"my_env", :organization => organization, :prior => organization.locker)}
     KTEnvironment.read_verbs.each do |verb|
       specify{user.allowed_to?(verb, :environments,environment.id,organization).should be_true}
       specify{user.allowed_to?(verb, :environments).should be_false}
       specify{global_user.allowed_to?(verb, :environments).should be_true}
     end
     specify{user.allowed_to?("update_systems", :environments,environment.id,organization).should be_false}
     specify{global_user.allowed_to?("update_systems", :environments,environment.id,organization).should be_false}
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