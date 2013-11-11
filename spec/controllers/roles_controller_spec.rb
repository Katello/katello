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

require 'katello_test_helper'

module Katello
describe RolesController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper

  module RolesControllerTest
    ADMIN_ID = 2
    ADMIN = { :name => "admin", :id => ADMIN_ID }
    ROLE = { :name => "Foo_Role" }
  end

  before(:each) do
    disable_user_orchestration
    setup_controller_defaults

    @organization = new_test_org
    @controller.stubs(:current_organization).returns(@organization)
    @controller.stubs(:search_validate).returns(true)
    @admin = Role.create(RolesControllerTest::ADMIN)
  end

  describe "create a role" do

    it "should create a role correctly (katello)" do #TODO headpin
      post 'create', {:role => RolesControllerTest::ROLE }
      must_respond_with(:success)
      Role.where(:name=>RolesControllerTest::ROLE[:name]).wont_be_empty
    end

    describe "with invalid params" do
      let(:req) do
        bad_req = {:role => {:bad_foo => "mwahaha"}.merge(RolesControllerTest::ROLE)}
        post :create, bad_req
      end
      it_should_behave_like "bad request"

      it "should error if no name (katello)" do #TODO headpin
        post 'create', {:role => {}}
        response.must_respond_with(422)
      end

      it "should error if blank name (katello)" do #TODO headpin
        post 'create', {:role => { :name=> "" }}
        response.must_respond_with(422)
      end
    end
  end

  describe "update a role" do
    before (:each) do
      @user = users(:restricted)
      @role = Role.create!(RolesControllerTest::ROLE)
    end

    it 'should allow changing of the name (katello)' do #TODO headpin
      put 'update', { :id => @role.id, :role => {  :name => "new_test_role_name"}}
      must_respond_with(:success)
      Role.where(:name=>"new_test_role_name").wont_be_empty
    end

    it "should be able to show the edit partial" do
      get :edit, :id=>@role.id
      must_respond_with(:success)
    end

    it "should be able to add a user to the role" do
      put 'update', { :id => @role.id, :update_users => { :adding => "true", :user_id => @user.id }}
      must_respond_with(:success)
      assigns[:role].users.must_include @user
    end

    it "should be able to remove a user from the role" do
      put 'update', { :id => @role.id, :update_users => { :adding => "false", :user_id => @user.id }}
      must_respond_with(:success)
      assigns[:role].users.wont_include @user
    end

    describe "with invalid params" do
      let(:req) do
        bad_req = {:role => {:description => "lame"}, :id=>@role.id}
        bad_req[:role][:bad_foo] = "mwahahahaha"
        put 'update', bad_req
      end
      it_should_behave_like "bad request"

      let(:req) do
        bad_req = {:update_users => {:adding => "false", :user_id => @user.id }, :id=>@role.id}
        bad_req[:update_users][:bad_foo] = "mwahahahaha"
        put 'update', bad_req
      end
      it_should_behave_like "bad request"
    end

=begin
    it 'should disallow changes to admin role' do
      post 'update', {:id=> RolesControllerTest::ADMIN_ID, :name=>"not an admin"}
      must_respond_with(:success)
      Role.where(:name=>"admin").wont_be_empty
    end
=end

  end

  describe "delete a role" do
    before (:each) do
      @role = Role.create(RolesControllerTest::ROLE)
    end

    it 'should successfully delete (katello)' do #TODO headpin
      delete 'destroy', :id => @role.id, :format => :js
      Role.exists?(@role.id).must_equal(false)
    end

    describe 'with wrong id' do
      it 'should thrown an exception (katello)' do #TODO headpin
        delete 'destroy', { :id => 13 }
        response.must_respond_with(404)
      end
    end
  end

  describe "viewing roles" do
    before (:each) do
      150.times{|a| Role.create!(:name=>"bar%05d" % [a])}
    end

    it "should show the role 2 pane list (katello)" do #TODO headpin
      get :index
      must_respond_with(:success)
      must_render_template("index")
    end

    it "should render list of roles" do
      @controller.stubs(:render)
      @controller.expects(:render_panel_direct)

      get :items
      must_respond_with(:success)
    end

  end

  describe "rules" do
    before (:each) do
      @organization = new_test_org
      @role = Role.create!(:name=>"TestRole")
    end
    describe "GET index" do
      let(:action) {:items}
      let(:req) { get :items }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :roles, nil, nil) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      let(:before_success) do
        @controller.stubs(:render)
        @controller.expects(:render_panel_direct)
      end

      it_should_behave_like "protected action"
    end

    describe "update user put" do

      let(:action) {:update}
      let(:req) do
        put 'update', :id => @role.id, :name=>"barfoo"
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :roles, nil, nil) }
      end
      let(:unauthorized_user) do
         user_with_permissions { |u| u.can(:read, :roles, nil, nil) }
      end
      it_should_behave_like "protected action"
    end
  end

  describe "create permission" do
    before (:each) do
      @organization = new_test_org
      @role = Role.create!(:name=>"TestRole")
    end

    it "should be successful" do
      must_notify_with(:success)
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'organizations' }, :name=> "New Perm"}}
      must_respond_with(:success)
      assigns[:role].permissions.must_include Permission.where(:name => "New Perm")[0]
    end

    it "with all types set should be successful" do
      must_notify_with(:success)
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'all' }, :name=> "New Perm"}}
      must_respond_with(:success)
      assigns[:role].permissions.must_include Permission.where(:name => "New Perm")[0]
    end

    describe "with bad requests" do
      let(:req) do
        put 'create_permission', { :role_id => @role.id, :name=> "New Perm",
                                   :permission => {:organization_id =>@organization.id, :bad_foo => "xyz"}}.with_indifferent_access
      end
      it_should_behave_like "bad request"

      let(:req) do
        put 'create_permission', { :role_id => @role.id, :name=> "New Perm",
                                   :permission => {:organization_id =>@organization.id,
                                                   :resource_type_attributes => {:bad_foo => "xyz", :name => 'all' }}}.with_indifferent_access
      end
      it_should_behave_like "bad request"
    end
  end

  describe 'destroy permission' do

    before (:each) do
      @organization = new_test_org
      @role = Role.create!(:name=>"TestRole")
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'all' }, :name=> "New Perm"}}
      @perm = Permission.where(:name => "New Perm")[0]
    end

    it "should remove the permission from the role and delete it (katello)" do #TODO headpin
      must_notify_with(:success)
      put "destroy_permission", { :role_id => @role.id, :permission_id => @perm.id}
      must_respond_with(:success)
      assigns[:role].permissions.wont_include @perm
    end

  end

  describe 'update permission' do

    before (:each) do
      @organization = new_test_org
      @role = Role.create!(:name=>"TestRole")
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'all' }, :name=> "New Perm"}}
      @perm = Permission.where(:name => "New Perm")[0]
    end

    it 'should change the name of the permission (katello)' do #TODO headpin
      must_notify_with(:success)
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :name => "New Named Perm"}}
      must_respond_with(:success)
      Permission.find(@perm.id).name.must_equal "New Named Perm"
    end

    it 'should change the description of the permission (katello)' do #TODO headpin
      must_notify_with(:success)
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :description => "This is the new description."}}
      must_respond_with(:success)
      Permission.find(@perm.id).description.must_equal "This is the new description."
    end

    it 'should set all verbs (katello)' do #TODO headpin
      must_notify_with(:success)
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :all_verbs => true }}
      must_respond_with(:success)
      Permission.find(@perm.id).all_verbs.must_equal true
    end

    it 'should set all tags (katello)' do #TODO headpin
      must_notify_with(:success)
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :all_tags => true }}
      must_respond_with(:success)
      Permission.find(@perm.id).all_tags.must_equal true
    end

    describe "with bad requests" do
      let(:req) do
        put "update_permission", { :role_id => @role.id, :permission_id => @perm.id,
                                   :permission => {:name=> "New Perm",  :bad_foo => "xyz"}}
      end
      it_should_behave_like "bad request"

      let(:req) do
        put "update_permission", { :role_id => @role.id, :permission_id => @perm.id,
                                   :permission => {:name=> "New Perm",
                                                   :resource_type_attributes => {:bad_foo => "xyz", :name => 'all' }}}
      end
      it_should_behave_like "bad request"
    end
  end

  describe 'getting verbs and tags' do

    it 'should return a json object of verbs and tags' do
      get 'verbs_and_scopes', { :organization_id => @organization.id }
      must_respond_with(:success)
    end

  end

end
end
