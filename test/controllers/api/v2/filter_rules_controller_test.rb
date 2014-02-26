# encoding: utf-8
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

require "katello_test_helper"

module Katello
  class Api::V2::FilterRulesControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["ContentView", "ContentViewEnvironment", "ContentViewVersion",
                "Repository", "Filter", "PackageFilter", "PackageFilterRule"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
      super
    end

    def models
      @filter = katello_filters(:simple_filter)
      @rule = katello_package_filter_rules(:package_rule)
    end

    def permissions
      @update_permission = UserPermission.new(:update, :content_views)
      @create_permission = UserPermission.new(:create, :content_views)
      @read_permission = UserPermission.new(:read, :content_views)
      @no_permission = NO_PERMISSION
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_index
      get :index, :filter_id => @filter.id

      assert_response :success
      assert_template 'api/v2/filter_rules/index'
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :filter_id => @filter.id
      end
    end

    def test_create
      post :create, :filter_id => @filter.id, :name => "testpkg", :version => "10.0"

      assert_response :success
      assert_template %w(katello/api/v2/filter_rules/show)
      assert_equal @filter.reload.package_rules.first.name, "testpkg"
      assert_equal @filter.package_rules.first.version, "10.0"
    end

    def test_create_protected
      allowed_perms = [@create_permission, @update_permission]
      denied_perms = [@read_permission, @no_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :filter_id => @filter.id, :name => "testpkg", :version => "10.0"
      end
    end

    def test_show
      get :show, :filter_id => @filter.id, :id => @rule.id

      assert_response :success
      assert_template 'api/v2/filter_rules/show'
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :filter_id => @filter.id, :id => @rule.id
      end
    end

    def test_update
      refute_equal @rule.name, "testpkg"
      refute_equal @rule.version, "10.0"

      put :update, :filter_id => @filter.id, :id => @rule.id, :name => "testpkg", :version => "10.0"

      assert_response :success
      assert_equal @rule.reload.name, "testpkg"
      assert_equal @rule.version, "10.0"
    end

    def test_update_protected
      allowed_perms = [@create_permission, @update_permission]
      denied_perms = [@no_permission, @read_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :filter_id => @filter.id, :id => @rule.id, :name => "new name"
      end
    end

    def test_destroy
      delete :destroy, :filter_id => @filter.id, :id => @rule.id

      assert_response :success
      assert_nil PackageFilterRule.find_by_id(@rule.id)
    end

    def test_destroy_protected
      allowed_perms = [@create_permission, @update_permission]
      denied_perms = [@read_permission, @no_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :filter_id => @filter.id, :id => @rule.id
      end
    end
  end
end
