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
  class Api::V2::ContentViewFilterRulesControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["ContentView", "ContentViewEnvironment", "ContentViewVersion",
                "Repository", "ContentViewFilter", "ContentViewPackageFilter",
                "ContentViewPackageFilterRule"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
      super
    end

    def models
      @filter = katello_content_view_filters(:simple_filter)
      @rule = katello_content_view_package_filter_rules(:package_rule)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
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
      get :index, :content_view_filter_id => @filter.id

      assert_response :success
      assert_template 'api/v2/content_view_filter_rules/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_filter_id => @filter.id
      end
    end

    def test_create
      post :create, :content_view_filter_id => @filter.id, :name => "testpkg", :version => "10.0"

      assert_response :success
      assert_template %w(katello/api/v2/content_view_filter_rules/show)
      assert_equal @filter.reload.package_rules.first.name, "testpkg"
      assert_equal @filter.package_rules.first.version, "10.0"
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :content_view_filter_id => @filter.id, :name => "testpkg", :version => "10.0"
      end
    end

    def test_show
      get :show, :content_view_filter_id => @filter.id, :id => @rule.id

      assert_response :success
      assert_template 'api/v2/content_view_filter_rules/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :content_view_filter_id => @filter.id, :id => @rule.id
      end
    end

    def test_update
      refute_equal @rule.name, "testpkg"
      refute_equal @rule.version, "10.0"

      put :update, :content_view_filter_id => @filter.id, :id => @rule.id, :name => "testpkg", :version => "10.0"

      assert_response :success
      assert_equal @rule.reload.name, "testpkg"
      assert_equal @rule.version, "10.0"
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :content_view_filter_id => @filter.id, :id => @rule.id, :name => "new name"
      end
    end

    def test_destroy
      delete :destroy, :content_view_filter_id => @filter.id, :id => @rule.id

      results = JSON.parse(response.body)
      refute results.blank?
      assert_equal results['id'], @rule.id

      assert_response :success
      assert_nil ContentViewPackageFilterRule.find_by_id(@rule.id)
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :content_view_filter_id => @filter.id, :id => @rule.id
      end
    end
  end
end
