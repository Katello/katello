# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentViewFilterRulesControllerTest < ActionController::TestCase
    def models
      @filter = katello_content_view_filters(:simple_filter)
      @package_group_filter = katello_content_view_filters(:populated_package_group_filter)
      @rule = katello_content_view_package_filter_rules(:test_package)
      @rule_for_different_filter = katello_content_view_package_filter_rules(:package_rule)
      @one_package_rule = katello_content_view_package_filter_rules(:one_package_rule)
      @package_group_rule = katello_content_view_package_group_filter_rules(:package_group_rule)
      @rpm = katello_rpms(:one)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index, params: { :content_view_filter_id => @filter.id }

      assert_response :success
      assert_template 'api/v2/content_view_filter_rules/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]
      assert_protected_action(:index, allowed_perms, denied_perms, [get_organization]) do
        get :index, params: { :content_view_filter_id => @filter.id }
      end
    end

    def test_create
      post :create, params: { :content_view_filter_id => @filter.id, :name => "testpkg", :version => "10.0" }

      assert_response :success

      assert_template :layout => 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'
      assert_includes @filter.reload.package_rules.pluck(:name), "testpkg"
      assert_includes @filter.package_rules.pluck(:version), "10.0"
    end

    def test_create_with_name_array
      post :create, params: { content_view_filter_id: @filter.id, name: %w(testpkg testpkg2), version: '10.0' }

      assert_response :success

      assert_template layout: 'katello/api/v2/layouts/collection'
      assert_template 'katello/api/v2/content_view_filter_rules/index'
      assert_equal @filter.reload.package_rules.sort.map(&:name).uniq.sort, %w(package\ def testpkg testpkg2 one).sort
      assert_equal @filter.package_rules.map(&:version).compact.sort, ["", "1.0", "10.0", "10.0"].sort
    end

    def test_create_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms, [get_organization]) do
        post :create, params: { :content_view_filter_id => @filter.id, :name => "testpkg", :version => "10.0" }
      end
    end

    def test_create_module_stream
      @filter = katello_content_view_filters(:populated_module_stream_filter)
      module_stream = katello_module_streams(:one)
      post :create, params: { :content_view_filter_id => @filter.id, :module_stream_ids => [module_stream.id] }

      assert_response :success

      assert_template :layout => 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'

      assert_equal @filter.reload.module_stream_rules.last.module_stream, module_stream
    end

    def test_show
      get :show, params: { :content_view_filter_id => @filter.id, :id => @rule.id }

      assert_response :success
      assert_template 'api/v2/content_view_filter_rules/show'
      body = JSON.parse(response.body)
      assert_nil body["matching_content"] # should only show up with the matching_content parameter
    end

    def test_mismatched_filter_and_rule
      get :show, params: { :content_view_filter_id => @filter.id, :id => @rule_for_different_filter.id }

      assert_response 404
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :content_view_filter_id => @filter.id, :id => @rule.id }
      end
    end

    def test_update
      refute_equal @rule.name, "testpkg"
      refute_equal @rule.version, "10.0"

      put :update, params: { :content_view_filter_id => @filter.id, :id => @rule.id, :name => "testpkg", :version => "10.0" }

      assert_response :success
      assert_equal @rule.reload.name, "testpkg"
      assert_equal @rule.version, "10.0"
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, params: { :content_view_filter_id => @filter.id, :id => @rule.id, :name => "new name" }
      end
    end

    def test_update_with_name_array
      refute_equal @rule.name, "testpkg"
      refute_equal @rule.version, "10.0"

      put :update, params: { content_view_filter_id: @filter.id, id: @rule.id, name: %w(testpkg), version: '10.0' }

      assert_response :success
      assert_equal @rule.reload.name, "testpkg"
      assert_equal @rule.version, "10.0"
    end

    def test_destroy
      delete :destroy, params: { :content_view_filter_id => @filter.id, :id => @rule.id }

      results = JSON.parse(response.body)
      refute results.blank?
      assert_equal results['id'], @rule.id

      assert_response :success
      assert_nil ContentViewPackageFilterRule.find_by_id(@rule.id)
    end

    def test_destroy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { :content_view_filter_id => @filter.id, :id => @rule.id }
      end
    end
  end
end
