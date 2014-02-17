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
  class Api::V2::ContentViewsControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["ContentView", "ContentViewEnvironment", "ContentViewVersion",
                "Repository"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
      @library = katello_environments(:library)
      @content_view = katello_content_views(:library_dev_view)
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
      ContentView.any_instance.stubs(:reindex_on_association_change).returns(true)
      models
      permissions
    end

    def test_index
      relation = ContentView.non_default
      ContentView.expects(:non_default).once.returns(relation)
      get :index, :organization_id => @organization.label

      assert_response :success
      assert_template 'api/v2/content_views/index'
    end

    def test_index_fail_without_organization_id
      get :index

      assert_response :not_found
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.label
      end
    end

    def test_create
      post :create, :name => "My View", :label => "My_View", :description => "Cool",
        :organization_id => @organization.label

      assert_response :success
      assert_template %w(katello/api/v2/content_views/show)
    end

    def test_create_fail_without_organization_id
      post :create, :name => "My View", :label => "My_View", :description => "Cool"

      assert_response :not_found
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@read_permission, @no_permission, @update_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :name => "Test", :organization_id => @organization.label
      end
    end

    def test_show
      relation = ContentView.non_default
      ContentView.expects(:non_default).once.returns(relation)
      get :show, :id => @content_view.id

      assert_response :success
      assert_template 'api/v2/content_views/show'
    end

    def test_show_fail_with_default
      content_view = katello_content_views(:acme_default)
      get :show, :id => content_view.id

      assert_response :not_found
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @content_view.id
      end
    end

    def test_update
      put :update, :id => @content_view, :name => "My View"

      assert_equal "My View", @content_view.reload.name
      assert_response :success
      assert_template 'api/v2/common/update'
    end

    def test_update_repositories
      repository = katello_repositories(:p_forge)
      refute_includes @content_view.repositories(true).map(&:id), repository.id
      put :update, :id => @content_view, :repository_ids => [repository.id]

      assert_response :success
      assert_includes @content_view.repositories(true).map(&:id), repository.id
    end

    def test_update_protected
      allowed_perms = [@create_permission, @update_permission]
      denied_perms = [@no_permission, @read_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @content_view.id, :name => "new name"
      end
    end
  end
end
