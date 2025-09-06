require 'katello_test_helper'

module Katello
  class Api::V2::ContentViewDebFilterRulesControllerTest < ActionController::TestCase
    fixtures :katello_content_view_filters,
             :katello_content_view_deb_filter_rules,
             :katello_debs

    tests Katello::Api::V2::ContentViewFilterRulesController

    def models
      @filter = katello_content_view_filters(:simple_deb_filter)
      @rule = katello_content_view_deb_filter_rules(:deb_test_package)
      @rule_other_filter = katello_content_view_deb_filter_rules(:deb_other_filter_rule)
      @arch_rule = katello_content_view_deb_filter_rules(:deb_arch_rule)
      @deb_one = katello_debs(:one)
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
      get :index, params: { content_view_filter_id: @filter.id }
      assert_response :success
      assert_template 'api/v2/content_view_filter_rules/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, params: { content_view_filter_id: @filter.id }
      end
    end

    def test_create_single_name
      post :create, params: { content_view_filter_id: @filter.id,
                              name: 'debtest', architecture: 'amd64',
                              version: '2.0' }
      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_includes @filter.reload.deb_rules.pluck(:name), 'debtest'
    end

    def test_create_name_array
      post :create, params: { content_view_filter_id: @filter.id,
                              name: %w(debtest debtest2),
                              architecture: '',
                              min_version: '1.0' }
      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/collection'
      names = @filter.reload.deb_rules.map(&:name).uniq
      assert_equal %w(archpkg debpkg debtest debtest2).sort, names.sort
    end

    def test_create_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, params: { content_view_filter_id: @filter.id,
                                name: 'debtest', version: '1.0' }
      end
    end

    def test_show
      get :show, params: { content_view_filter_id: @filter.id, id: @arch_rule.id }
      assert_response :success
      assert_template 'api/v2/content_view_filter_rules/show'
    end

    def test_mismatched_filter_and_rule
      get :show, params: { content_view_filter_id: @filter.id, id: @rule_other_filter.id }
      assert_response 404
    end

    def test_update
      put :update, params: { content_view_filter_id: @filter.id,
                             id: @arch_rule.id,
                             name: 'updatepkg',
                             architecture: 'arm64',
                             max_version: '3.0' }
      assert_response :success
      assert_equal 'updatepkg', @arch_rule.reload.name
      assert_equal 'arm64', @arch_rule.reload.architecture
      assert_equal '3.0', @arch_rule.max_version
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, params: { content_view_filter_id: @filter.id,
                               id: @arch_rule.id, name: 'oops' }
      end
    end

    def test_destroy
      delete :destroy, params: { content_view_filter_id: @filter.id, id: @arch_rule.id }
      assert_response :success
      assert_nil ContentViewDebFilterRule.find_by_id(@arch_rule.id)
    end

    def test_destroy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { content_view_filter_id: @filter.id, id: @arch_rule.id }
      end
    end
  end
end
