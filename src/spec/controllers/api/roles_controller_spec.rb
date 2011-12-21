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

describe Api::RolesController do
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

  before (:each) do
    @role= Role.new(:name => "test_role", :description=> "role description")
    Role.stub(:find).with("123").and_return(@role)
  end

  describe "list roles" do
    let(:action) { :index }
    let(:req) { get :index }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"
  end

  describe "show role" do
    let(:action) { :show }
    let(:req) { get :show, :id => "123" }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"
  end

  describe "create role" do
    let(:action) { :create }
    let(:req) { post :create }
    let(:authorized_user) { user_with_create_permissions }
    let(:unauthorized_user) { user_without_create_permissions }
    it_should_behave_like "protected action"
  end

  describe "update role" do
    let(:action) { :update }
    let(:req) { put :update, :id => "123" }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"
  end

  describe "destroy role" do
    let(:action) { :destroy }
    let(:req) { delete :destroy, :id => "123" }
    let(:authorized_user) { user_with_destroy_permissions }
    let(:unauthorized_user) { user_without_destroy_permissions }
    it_should_behave_like "protected action"
  end
end

