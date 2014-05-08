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
  class Api::V2::ContentViewVersionsControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["ContentView", "ContentViewEnvironment", "ContentViewVersion", "LifecycleEnvironment",
                "Repository"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
      @library = LifecycleEnvironment.find(katello_environments(:library))
      @dev = LifecycleEnvironment.find(katello_environments(:dev))
      @content_view = ContentView.find(katello_content_views(:library_dev_view))
    end

    def permissions
      @update_permission = UserPermission.new(:update, :content_views)
      @create_permission = UserPermission.new(:create, :content_views)
      @read_permission = UserPermission.new(:read, :content_views)
      @promote_permission = UserPermission.new(:promote_changesets, :environments) +
          UserPermission.new(:promote, :content_views)
      @no_permission = NO_PERMISSION
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
      ContentViewVersion.any_instance.stubs(:package_count).returns(0)
      ContentViewVersion.any_instance.stubs(:errata_count).returns(0)
    end

    def test_index
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      get :index, :content_view_id => @content_view.id
      assert_response :success
      assert_template 'api/v2/content_view_versions/index'

      get :index
      assert_response 404
    end

    def test_index_protected
      allowed_perms = [@read_permission, @update_permission, @create_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @content_view.id
      end
    end

    def test_show
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      get :show, :id => @content_view.versions.first.id
      assert_response :success
      assert_template 'api/v2/content_view_versions/show'
    end

    def test_show_protected
      allowed_perms = [@read_permission, @update_permission, @create_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @content_view.id
      end
    end

    def test_promote
      version = @content_view.versions.first
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::Promote, version, @dev).returns({})
      post :promote, :id => version.id, :environment_id => @dev.id

      assert_response :success
      assert_template 'katello/api/v2/common/async'
    end

    def test_promote_protected
      allowed_perms = [@promote_permission]
      denied_perms = [@read_permission, @update_permission, @create_permission, @no_permission]

      assert_protected_action(:promote, allowed_perms, denied_perms) do
        post :promote, :id => @content_view.versions.first.id, :environment_id => @dev.id
      end
    end

    def test_promote_default
      view = ContentView.find(katello_content_views(:acme_default))
      post :promote, :id => view.versions.first.id, :environment_id => @dev.id
      assert_response 400
    end
  end
end
