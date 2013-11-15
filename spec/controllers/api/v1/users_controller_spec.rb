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
describe Api::V1::UsersController do
  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper

  before do
    setup_engine_routes
    disable_user_orchestration
  end
  describe "perms" do
    let(:user_with_read_permissions) { user_with_permissions { |u| u.can(:read, :users) } }
    let(:user_without_read_permissions) { user_without_permissions }
    let(:user_with_create_permissions) { user_with_permissions { |u| u.can(:create, :users) } }
    let(:user_without_create_permissions) { user_with_permissions { |u| u.can(:read, :users) } }
    let(:user_with_update_permissions) { user_with_permissions { |u| u.can(:update, :users) } }
    let(:user_without_update_permissions) { user_with_permissions { |u| u.can(:read, :users) } }
    let(:user_with_destroy_permissions) { user_with_permissions { |u| u.can(:delete, :users) } }
    let(:user_without_destroy_permissions) { user_with_permissions { |u| u.can(:update, :users) } }

    before (:each) do
      @user = User.new(:login => "test_user", :password => "123")
      User.stubs(:find).with("123").returns(@user)
    end

    describe "show users" do
      let(:action) { :index }
      let(:req) { get :index }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it "should_behave_like 'protected action'" do
        skip("TODO: these should be deleted once integration with foreman has accounted for them")
      end
    end

    describe "show user" do
      let(:action) { :show }
      let(:req) { get :show, :id => "123" }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it "should_behave_like 'protected action'" do
        skip("TODO: these should be deleted once integration with foreman has accounted for them")
      end
    end

    describe "create user" do
      let(:action) { :create }
      let(:req) { post :create, { :login => "eric", :password => "redhat", :mail => "foo@redhat.com" } }
      let(:authorized_user) { user_with_create_permissions }
      let(:unauthorized_user) { user_without_create_permissions }
      it "should_behave_like 'protected action'" do
        skip("TODO: these should be deleted once integration with foreman has accounted for them")
      end
    end

    describe "update user" do
      let(:action) { :update }
      let(:req) { put :update, { :id => "123", :user => { :disabled => false } } }
      let(:authorized_user) { user_with_update_permissions }
      let(:unauthorized_user) { user_without_update_permissions }
      it "should_behave_like 'protected action'" do
        skip("TODO: these should be deleted once integration with foreman has accounted for them")
      end
    end

    describe "destroy user" do
      let(:action) { :destroy }
      let(:req) { delete :destroy, :id => "123" }
      let(:authorized_user) { user_with_destroy_permissions }
      let(:unauthorized_user) { user_without_destroy_permissions }
      it "should_behave_like 'protected action'" do
        skip("TODO: these should be deleted once integration with foreman has accounted for them")
      end
    end
  end

  describe "create" do
    before do
      setup_controller_defaults_api
      @request.env["HTTP_ACCEPT"] = "application/json"
    end
    let(:request_params) do
      { :login => "arnold",
        :password => "terminator",
        :mail    => "arnold@redhat.com",
        :auth_source_id => 1000,
        :disabled => true
      }.with_indifferent_access
    end
    describe "invalid params" do
      let(:req) do
        bad_req           = request_params
        bad_req[:bad_foo] = "mwahaha"
        post :create, bad_req
      end
      it "should_behave_like 'bad request'" do
        skip("TODO: these should be deleted once integration with foreman has accounted for them")
      end
    end

    it "must_be successful" do
      skip("TODO: these should be deleted once integration with foreman has accounted for them")
      post :create, request_params
      must_respond_with(:success)
      User.last.wont_be_nil
      User.last.login.must_equal request_params[:login]
      User.last.disabled?.must_equal request_params[:disabled]
    end
  end

  describe "update" do
    before do
      setup_controller_defaults_api
      @request.env["HTTP_ACCEPT"] = "application/json"
    end

    let(:user) { User.create!(:login => "foo", :password => "redhat123",
                              :mail    => "jomara@redhat.com", :disabled => false) }
    let(:request_params) {
      { :id   => user.id,
        :user =>
            { :password => "--Altered",
              :disabled => true
            }
      }.with_indifferent_access
    }

    describe "invalid params" do
      let(:req) do
        bad_req                  = request_params
        bad_req[:user][:bad_foo] = "mwahaha"
        put :update, bad_req
      end
      it "should_behave_like 'bad request'" do
        skip("TODO: these should be deleted once integration with foreman has accounted for them")
      end
    end


    it "must_be successful" do
      skip("TODO: these should be deleted once integration with foreman has accounted for them")

      old_pass = user.password
      put :update, request_params
      must_respond_with(:success)
      User.last.wont_be_nil
      User.last.password.should_not == old_pass
      User.last.disabled?.must_equal request_params[:user][:disabled]
    end
  end

end

end