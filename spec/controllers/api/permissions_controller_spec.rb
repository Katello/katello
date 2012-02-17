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

require 'spec_helper.rb'
include OrchestrationHelper

describe Api::PermissionsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can(:read, :roles) } }
  let(:user_without_read_permissions) { user_without_permissions }
  let(:user_with_create_permissions) { user_with_permissions { |u| u.can(:create, :roles) } }
  let(:user_without_create_permissions) { user_with_permissions { |u| u.can(:read, :roles) } }
  let(:user_with_destroy_permissions) { user_with_permissions { |u| u.can(:delete, :roles) } }
  let(:user_without_destroy_permissions) { user_with_permissions { |u| u.can(:update, :roles) } }

  let(:role_id) { 123 }
  let(:perm_id) { 456 }

  before (:each) do
    @role = Role.new(:name => "test_role", :description=> "role description")
    @perm = Permission.new(:name => "permission_x", :description => "permission description", :role => @role)
    Role.stub(:find).with(role_id).and_return(@role)
    Permission.stub(:find).with(perm_id).and_return(@perm)

    login_user_api
  end

  describe "list permissions" do
    let(:action) { :index }
    let(:req) { get :index, :role_id => role_id }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it 'should find the role' do
      Role.should_receive(:find).with(role_id)
      req
    end

    it 'should find all permissions associated with the role' do
      @role.permissions.should_receive(:where).and_return([])
      req
    end
  end

  describe "show permission" do
    let(:action) { :show }
    let(:req) { get :show, :role_id => role_id, :id => perm_id }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it 'should find the permission' do
      Permission.should_receive(:find).with(perm_id)
      req
    end
  end

  describe "create permission" do
    let(:perm_name) { 'permission_y' }
    let(:perm_desc) { 'permission_y description' }
    let(:resource_type) { 'environments' }
    let(:perm_params) { {:name => perm_name, :description => perm_desc, 'type' => resource_type, 'verbs' => [], 'tags' => [], :role_id => role_id} }
    let(:action) { :create }
    let(:req) { post :create, perm_params }
    let(:authorized_user) { user_with_create_permissions }
    let(:unauthorized_user) { user_without_create_permissions }
    it_should_behave_like "protected action"


    it 'should find the role' do
      Role.should_receive(:find).with(role_id)
      req
    end

    it 'should create a permission' do
        @resource_type = ResourceType.new(:name => resource_type)
        ResourceType.should_receive(:find_or_create_by_name).with(resource_type).and_return(@resource_type)

        expected_params = {
            :name => perm_name,
            :description => perm_desc,
            :role => @role,
            :resource_type => @resource_type
        }

        Permission.should_receive(:create!).with(hash_including(expected_params))
        req
    end
  end

  describe "destroy permission" do
    let(:action) { :destroy }
    let(:req) { delete :destroy, :role_id => role_id, :id => perm_id }
    let(:authorized_user) { user_with_destroy_permissions }
    let(:unauthorized_user) { user_without_destroy_permissions }
    it_should_behave_like "protected action"

    it 'should find the permission' do
      Permission.should_receive(:find).with(perm_id)
      req
    end

    it 'should destroy the permission' do
      @perm.should_receive(:destroy)
      req
    end

  end

end

