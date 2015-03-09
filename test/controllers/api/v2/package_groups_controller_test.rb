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
  class Api::V2::PackageGroupsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64_dev))
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products

      @auth_permissions = [@read_permission]
      @unauth_permissions = [@create_permission, @update_permission, @destroy_permission, @sync_permission]
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
      get :index, :repository_id => @repo.id

      assert_response :success
      assert_template %w(katello/api/v2/package_groups/index)
    end

    def test_index_with_content_view_version
      get :index, :content_view_version_id => ContentViewVersion.first.id
      assert_response :success
      assert_template %w(katello/api/v2/package_groups/index)
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by_id => environment))

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template %w(katello/api/v2/package_groups/index)
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index, :repository_id => @repo.id
      end
    end

    def test_show
      PackageGroup.expects(:find).once.returns(stub(:repo_id => @repo.pulp_id))
      get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"

      assert_response :success
      assert_template %w(katello/api/v2/package_groups/show)
    end

    def test_show_group_not_found
      PackageGroup.expects(:find).once.returns(nil)
      get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
      assert_response 404
    end

    def test_show_protected
      pckage_group = stub
      pckage_group.stubs(:repo_id).returns([@repo.pulp_id])
      PackageGroup.stubs(:find).with("3805853f-5cae-4a4a-8549-0ec86410f58f").returns(pckage_group)

      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
      end
    end
  end
end
