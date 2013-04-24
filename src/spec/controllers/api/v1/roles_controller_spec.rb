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

require 'spec_helper.rb'
include OrchestrationHelper

describe Api::V1::RolesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can(:read, :roles) } }
  let(:user_without_read_permissions) { user_without_permissions }
  let(:user_with_create_permissions) { user_with_permissions { |u| u.can(:create, :roles) } }
  let(:user_without_create_permissions) { user_with_permissions { |u| u.can(:read, :roles) } }
  let(:user_with_update_permissions) { user_with_permissions { |u| u.can(:update, :roles) } }
  let(:user_without_update_permissions) { user_with_permissions { |u| u.can(:read, :roles) } }
  let(:user_with_destroy_permissions) { user_with_permissions { |u| u.can(:delete, :roles) } }
  let(:user_without_destroy_permissions) { user_with_permissions { |u| u.can(:update, :roles) } }

  let(:role_id) { '123' }

  before (:each) do
    @role= Role.new(:name => "test_role", :description=> "role description")
    Role.stub(:find).with(role_id.to_s).and_return(@role)

    login_user_api
  end

  describe "list roles" do
    let(:action) { :index }
    let(:req) { get :index }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it 'should find all roles' do
      Role.should_receive(:readable).and_return(Role)
      Role.should_receive(:non_self).once.and_return(Role)
      Role.should_receive(:where).once.and_return([@role])
      req
    end
  end

  describe "show role" do
    let(:action) { :show }
    let(:req) { get :show, :id => role_id }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it 'should find a role' do
      Role.should_receive(:find).with(role_id.to_s)
      req
    end
  end

  describe "create role" do
    let(:role_params) { {'name' => 'role_1'} }
    let(:action) { :create }
    let(:req) { post :create, :role => role_params }
    let(:authorized_user) { user_with_create_permissions }
    let(:unauthorized_user) { user_without_create_permissions }
    it_should_behave_like "protected action"

    it 'should create a role' do
        Role.should_receive(:create!).with(role_params)
        req
    end
    describe "with invalid params" do
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:role => {:bad_foo => "mwahaha"}.merge(role_params)}
          post :create, bad_req
        end
      end
    end
  end

  describe "update role" do
    let(:role_params) { {'name' => 'role_1'} }
    let(:action) { :update }
    let(:req) { put :update, :id => role_id, :role => role_params }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    before :each do
      @role.stub(:save!).and_return(true)
      @role.stub(:update_attributes!).and_return(true)
    end

    it 'should find the role' do
      Role.should_receive(:find).with(role_id.to_s)
      req
    end

    it 'should update role\'s params' do
      @role.should_receive(:update_attributes!).with(role_params)
      req
    end

    it 'should save the changes' do
      @role.should_receive(:save!)
      req
    end
    describe "with invalid params" do
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:id => role_id, :role => {:bad_foo => "mwahaha"}.merge(role_params)}
          put :update, bad_req
        end
      end
    end

  end

  describe "destroy role" do
    let(:action) { :destroy }
    let(:req) { delete :destroy, :id => role_id }
    let(:authorized_user) { user_with_destroy_permissions }
    let(:unauthorized_user) { user_without_destroy_permissions }
    it_should_behave_like "protected action"

    it 'should find the role' do
      Role.should_receive(:find).with(role_id)
      req
    end

    it 'should destroy the role' do
      @role.should_receive(:destroy)
      req
    end

  end

end

