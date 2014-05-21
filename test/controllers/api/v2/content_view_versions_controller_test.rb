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
      models = ["ContentView", "ContentViewEnvironment", "ContentViewVersion", "KTEnvironment",
                "Repository"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
      @library = KTEnvironment.find(katello_environments(:library))
      @dev = KTEnvironment.find(katello_environments(:dev))
      @library_dev_staging_view = ContentView.find(katello_content_views(:library_dev_staging_view))
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
      @env_promote_permission = :promote_or_remove_content_views_to_environments
      @cv_promote_permission = :promote_or_remove_content_views

      @dev_env_promote_permission = {:name=> @env_promote_permission, :search => "name=\"#{@dev.name}\"" }
      @library_dev_staging_view_promote_permission = {:name=> @cv_promote_permission, :search => "name=\"#{@library_dev_staging_view.name}\"" }
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
      ContentViewVersion.any_instance.stubs(:package_count).returns(0)
      ContentViewVersion.any_instance.stubs(:errata_count).returns(0)
    end

    def test_index
      get :index

      assert_response 404
    end

    def test_index_with_content_view
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      get :index, :content_view_id => @library_dev_staging_view.id
      assert_response :success
      assert_template 'api/v2/content_view_versions/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @library_dev_staging_view.id
      end
    end

    def test_show
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      get :show, :id => @library_dev_staging_view.versions.first.id
      assert_response :success
      assert_template 'api/v2/content_view_versions/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @library_dev_staging_view.id
      end
    end

    def test_promote
      version = @library_dev_staging_view.versions.first
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::Promote, version, @dev).returns({})
      post :promote, :id => version.id, :environment_id => @dev.id

      assert_response :success
      assert_template 'katello/api/v2/common/async'
    end

    def test_promote_protected
      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv))
      diff_env = KTEnvironment.find(katello_environments(:staging))
      diff_env_promote_permission = {:name=> @env_promote_permission, :search => "name=\"#{diff_env.name}\"" }
      diff_view_promote_permission = {:name=> @cv_promote_permission, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [[@env_promote_permission, @cv_promote_permission],
                       [@dev_env_promote_permission, @library_dev_staging_view_promote_permission],
                       [@dev_env_promote_permission, @cv_promote_permission],
                       [@env_promote_permission, @library_dev_staging_view_promote_permission]
                      ]
      denied_perms = [@view_permission, @create_permission, @update_permission, @destroy_permission,
                      @env_promote_permission, @cv_promote_permission,
                      [diff_env_promote_permission, @cv_promote_permission],
                      [@env_promote_permission, diff_view_promote_permission],
                      ]
      assert_protected_action(:promote, allowed_perms, denied_perms) do
        post :promote, :id => @library_dev_staging_view.versions.first.id, :environment_id => @dev.id
      end
    end

    def test_promote_default
      view = ContentView.find(katello_content_views(:acme_default))
      post :promote, :id => view.versions.first.id, :environment_id => @dev.id
      assert_response 400
    end

    def test_destroy_protected
      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv))
      diff_view_destroy_permission = {:name=> @destroy_permission, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [@destroy_permission]

      denied_perms = [@view_permission, @create_permission, @update_permission, @cv_promote_permission, diff_view_destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        post :destroy, :id => @library_dev_staging_view.versions.first.id
      end

    end

  end
end
