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
include OrchestrationHelper

describe RolesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  module RolesControllerTest
    ADMIN_ID = 2
    ADMIN = { :name => "admin", :id => ADMIN_ID }
    ROLE = { :name => "Foo_Role" }
  end

  before(:each) do
    disable_user_orchestration

    @user = login_user(:mock=>false)
    set_default_locale

    @organization = new_test_org
    controller.stub!(:current_organization).and_return(@organization)
    controller.stub(:search_validate).and_return(true)
    @admin = Role.create(RolesControllerTest::ADMIN)
  end

  describe "create a role" do

    it "should create a role correctly", :katello => true do #TODO headpin
      post 'create', {:role => RolesControllerTest::ROLE }
      response.should be_success
      Role.where(:name=>RolesControllerTest::ROLE[:name]).should_not be_empty
    end

    describe "with invalid params" do
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:role => {:bad_foo => "mwahaha"}.merge(RolesControllerTest::ROLE)}
          post :create, bad_req
        end
      end
      it "should error if no name", :katello => true do #TODO headpin
        post 'create', {:role => {}}
        response.should_not be_success
      end

      it "should error if blank name", :katello => true do #TODO headpin
        post 'create', {:role => { :name=> "" }}
        response.should_not be_success
      end
    end
  end

  describe "update a role" do
    before (:each) do
      @role = Role.create(RolesControllerTest::ROLE)
    end

    it 'should allow changing of the name', :katello => true do #TODO headpin
      put 'update', { :id => @role.id, :role => {  :name => "new_test_role_name"}}
      response.should be_success
      Role.where(:name=>"new_test_role_name").should_not be_empty
    end

    it "should be able to show the edit partial" do
      get :edit, :id=>@role.id
      response.should be_success
    end

    it "should be able to add a user to the role" do
      put 'update', { :id => @role.id, :update_users => { :adding => "true", :user_id => @user.id }}
      response.should be_success
      assigns[:role].users.should include @user
    end

    it "should be able to remove a user from the role" do
      put 'update', { :id => @role.id, :update_users => { :adding => "false", :user_id => @user.id }}
      response.should be_success
      assigns[:role].users.should_not include @user
    end

    describe "with invalid params" do
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:role => {:description => "lame"}, :id=>@role.id}
          bad_req[:role][:bad_foo] = "mwahahahaha"
          put 'update', bad_req
        end
      end
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:update_users => {:adding => "false", :user_id => @user.id }, :id=>@role.id}
          bad_req[:update_users][:bad_foo] = "mwahahahaha"
          put 'update', bad_req
        end
      end
    end

=begin
    it 'should disallow changes to admin role' do
      post 'update', {:id=> RolesControllerTest::ADMIN_ID, :name=>"not an admin"}
      response.should be_success
      Role.where(:name=>"admin").should_not be_empty
    end
=end

  end

  describe "delete a role" do
    before (:each) do
      @role = Role.create(RolesControllerTest::ROLE)
    end

    it 'should successfully delete', :katello => true do #TODO headpin
      delete 'destroy', :id => @role.id, :format => :js
      Role.exists?(@role.id).should be_false
    end

    describe 'with wrong id' do
      it 'should thrown an exception', :katello => true do #TODO headpin
        delete 'destroy', { :id => 13 }
        response.should_not be_success
      end
    end
  end

  describe "viewing roles" do
    render_views

    before (:each) do
      150.times{|a| Role.create!(:name=>"bar%05d" % [a])}
    end

    it "should show the role 2 pane list", :katello => true do #TODO headpin
      get :index
      response.should be_success
      response.should render_template("index")
    end

    it "should render list of roles" do

      controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
        controller.stub(:render)
      }

      get :items
      response.should be_success
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
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
          controller.stub(:render)
        }
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
      controller.should notify.success
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'organizations' }, :name=> "New Perm"}}
      response.should be_success
      assigns[:role].permissions.should include Permission.where(:name => "New Perm")[0]
    end

    it "with all types set should be successful" do
      controller.should notify.success
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'all' }, :name=> "New Perm"}}
      response.should be_success
      assigns[:role].permissions.should include Permission.where(:name => "New Perm")[0]
    end

    describe "with bad requests" do
      it_should_behave_like "bad request"  do
        let(:req) do
          put 'create_permission', { :role_id => @role.id, :name=> "New Perm",
                                     :permission => {:organization_id =>@organization.id, :bad_foo => "xyz"}}.with_indifferent_access
        end
      end
      it_should_behave_like "bad request"  do
        let(:req) do
          put 'create_permission', { :role_id => @role.id, :name=> "New Perm",
                                     :permission => {:organization_id =>@organization.id,
                                                     :resource_type_attributes => {:bad_foo => "xyz", :name => 'all' }}}.with_indifferent_access
        end
      end
    end
  end

  describe 'destroy permission' do

    before (:each) do
      @organization = new_test_org
      @role = Role.create!(:name=>"TestRole")
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'all' }, :name=> "New Perm"}}
      @perm = Permission.where(:name => "New Perm")[0]
    end

    it "should remove the permission from the role and delete it", :katello => true do #TODO headpin
      controller.should notify.success
      put "destroy_permission", { :role_id => @role.id, :permission_id => @perm.id}
      response.should be_success
      assigns[:role].permissions.should_not include @perm
    end

  end

  describe 'update permission' do

    before (:each) do
      @organization = new_test_org
      @role = Role.create!(:name=>"TestRole")
      put "create_permission", { :role_id => @role.id, :permission => { :resource_type_attributes => { :name => 'all' }, :name=> "New Perm"}}
      @perm = Permission.where(:name => "New Perm")[0]
    end

    it 'should change the name of the permission', :katello => true do #TODO headpin
      controller.should notify.success
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :name => "New Named Perm"}}
      response.should be_success
      Permission.find(@perm.id).name.should == "New Named Perm"
    end

    it 'should change the description of the permission', :katello => true do #TODO headpin
      controller.should notify.success
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :description => "This is the new description."}}
      response.should be_success
      Permission.find(@perm.id).description.should == "This is the new description."
    end

    it 'should set all verbs', :katello => true do #TODO headpin
      controller.should notify.success
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :all_verbs => true }}
      response.should be_success
      Permission.find(@perm.id).all_verbs.should == true
    end

    it 'should set all tags', :katello => true do #TODO headpin
      controller.should notify.success
      put "update_permission", { :role_id => @role.id, :permission_id => @perm.id, :permission => { :all_tags => true }}
      response.should be_success
      Permission.find(@perm.id).all_tags.should == true
    end

    describe "with bad requests" do
      it_should_behave_like "bad request"  do
        let(:req) do
          put "update_permission", { :role_id => @role.id, :permission_id => @perm.id,
                                     :permission => {:name=> "New Perm",  :bad_foo => "xyz"}}
        end
      end
      it_should_behave_like "bad request"  do
        let(:req) do
          put "update_permission", { :role_id => @role.id, :permission_id => @perm.id,
                                     :permission => {:name=> "New Perm",
                                                     :resource_type_attributes => {:bad_foo => "xyz", :name => 'all' }}}
        end
      end
    end
  end

  describe 'getting verbs and tags' do

    it 'should return a json object of verbs and tags' do
      get 'verbs_and_scopes', { :organization_id => @organization.id }
      response.should be_success
    end

  end

end
