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
      models
      permissions
    end

    def test_index
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
  end
end
