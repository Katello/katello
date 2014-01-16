# encoding: utf-8
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

require "katello_test_helper"

module Katello
  class Api::V2::SyncPlansControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["SyncPlan"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization(:organization1)
      @sync_plan = katello_sync_plans(:sync_plan_hourly)
    end

    def permissions
      @read_permission = UserPermission.new(:read, :providers)
      @create_permission = UserPermission.new(:create, :providers)
      @update_permission = UserPermission.new(:update, :providers)
      @no_permission = NO_PERMISSION
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_index
      get :index, :organization_id => @organization.label

      assert_response :success
      assert_template 'api/v2/sync_plans/index'
    end

    def test_index_protected
      allowed_perms = [@read_permission, @update_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.label
      end
    end

    def test_create
      post :create, :organization_id => @organization.label,
           :sync_plan => {:name => 'Hourly Sync Plan',
                          :sync_date => '2014-01-09 17:46:00',
                          :interval => 'hourly',
                          :description => 'This is my cool new product.'}

      assert_response :success
      assert_template 'api/v2/sync_plans/show'
    end

    def test_create_fail
      post :create, :organization_id => @organization.label,
           :sync_plan => {:sync_date => '2014-01-09 17:46:00',
                          :description => 'This is my cool new sync plan.'}

      assert_response :unprocessable_entity
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :organization_id => @organization.label,
             :sync_plan => {:name => 'Hourly Sync Plan',
                            :sync_date => '2014-01-09 17:46:00',
                            :interval => 'hourly'}
      end
    end

    def test_update
      put :update, :id => @sync_plan.id, :organization_id => @organization.label,
          :sync_plan => {:name => 'New Name'}

      assert_response :success
      assert_template 'api/v2/sync_plans/show'
      assert_equal assigns[:sync_plan].name, 'New Name'
    end

    def test_update_protected
      allowed_perms = [@update_permission, @create_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        put :update, :id => @sync_plan.id, :organization_id => @organization.label,
            :sync_plan => {:description => 'new description.'}
      end
    end

    def test_destroy
      delete :destroy, :organization_id => @organization.label, :id => @sync_plan.id

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@update_permission, @create_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :organization_id => @organization.label, :id => @sync_plan.id
      end
    end

  end
end
