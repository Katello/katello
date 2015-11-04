# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentViewFilterRulesControllerTest < ActionController::TestCase
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
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

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
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :content_view_filter_id => @filter.id, :id => @rule.id
      end
    end
  end
end
