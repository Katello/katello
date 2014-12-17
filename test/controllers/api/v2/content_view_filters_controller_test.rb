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
  class Api::V2::ContentViewFiltersControllerTest < ActionController::TestCase
    def self.before_suite
      models = ["ContentView", "ContentViewEnvironment", "ContentViewVersion",
                "Repository", "Product"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
      ::Katello::Erratum.any_instance.stubs(:repositories).returns([])
      super
    end

    def models
      @content_view = katello_content_views(:library_view)
      @filter = katello_content_view_filters(:simple_filter)
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
      Repository.any_instance.stubs(:last_sync).returns(Time.now.asctime)
      models
      permissions
      [:package_group_count, :package_count, :puppet_module_count].each do |content_type_count|
        Repository.any_instance.stubs(content_type_count).returns(0)
      end
    end

    def test_index
      get :index, :content_view_id => @content_view.id

      assert_response :success
      assert_template 'api/v2/content_view_filters/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @content_view.id
      end
    end

    def test_create
      @content_view = katello_content_views(:library_dev_view)
      assert_empty @content_view.filters

      post :create, :content_view_id => @content_view.id, :name => "My Filter", :type => "rpm"

      assert_response :success
      assert_template %w(katello/api/v2/content_view_filters/show)
      assert_includes @content_view.reload.filters.map(&:name), "My Filter"
    end

    def test_create_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :name => "Test", :content_view_id => @content_view.id
      end
    end

    def test_show
      get :show, :content_view_id => @filter.content_view_id, :id => @filter.id

      assert_response :success
      assert_template 'api/v2/content_view_filters/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :content_view_id => @filter.content_view_id, :id => @filter.id
      end
    end

    def test_update_name
      put :update, :content_view_id => @filter.content_view_id, :id => @filter, :name => "New Filter Name"
      assert_response :success
      assert_template 'api/v2/common/update'
      assert_equal @filter.reload.name, "New Filter Name"
    end

    def test_update_repositories
      repository = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      assert_includes @content_view.repositories.map(&:id), repository.id
      refute_includes @filter.repositories(true).map(&:id), repository.id

      put :update, :content_view_id => @filter.content_view_id, :id => @filter,
          :repository_ids => [repository.id]

      assert_response :success
      assert_includes @filter.repositories(true).map(&:id), repository.id
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :content_view_id => @filter.content_view_id, :id => @filter.id, :name => "new name"
      end
    end

    def test_destroy
      delete :destroy, :content_view_id => @filter.content_view_id, :id => @filter.id

      results = JSON.parse(response.body)
      refute results.blank?
      assert_equal results['id'], @filter.id

      assert_response :success
      assert_nil ContentViewFilter.find_by_id(@filter.id)
    end

    def test_destroy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :content_view_id => @filter.content_view_id, :id => @filter.id
      end
    end

    def test_available_errata
      @filter = katello_content_view_filters(:populated_erratum_filter)
      get :available_errata, :content_view_id => @filter.content_view_id, :id => @filter.id

      assert_response :success
      assert_template 'katello/api/v2/content_view_filters/../errata/index'
    end

    def test_available_errata_protected
      @filter = katello_content_view_filters(:populated_erratum_filter)
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:available_errata, allowed_perms, denied_perms) do
        get :available_errata, :content_view_id => @filter.content_view_id, :id => @filter.id
      end
    end

    def test_available_package_groups
      @filter = katello_content_view_filters(:populated_package_group_filter)
      get :available_package_groups, :content_view_id => @filter.content_view_id, :id => @filter.id

      assert_response :success
      assert_template 'katello/api/v2/content_view_filters/../package_groups/index'
    end

    def test_available_package_groups_protected
      @filter = katello_content_view_filters(:populated_package_group_filter)
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:available_package_groups, allowed_perms, denied_perms) do
        get :available_package_groups, :content_view_id => @filter.content_view_id, :id => @filter.id
      end
    end
  end
end
