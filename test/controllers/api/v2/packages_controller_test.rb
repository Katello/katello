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
  class Api::V2::PackagesControllerTest < ActionController::TestCase

    def before_suite
      models = ["Organization", "KTEnvironment", "Package", "Repository", "Product"]
      services = ["Candlepin", "Pulp", "ElasticSearch"]
      disable_glue_layers(services, models)
      super
    end

    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64_dev))
      @version = ContentViewVersion.first
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products

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
      assert_template %w(katello/api/v2/packages/index)

      get :index, :content_view_version_id => @version.id

      assert_response :success
      assert_template %w(katello/api/v2/packages/index)
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by_id => environment))

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template %w(katello/api/v2/packages/index)
    end

    def test_index_parameters
      get :index

      assert_response :success
    end

    def test_index_protected
      assert_protected_action(:index, @read_permission, @unauth_permissions) do
        get :index, :repository_id => @repo.id
      end
    end

    def test_show
      package = stub
      package.stubs(:repoids).returns([@repo.pulp_id])
      Package.expects(:find).once.with("3805853f-5cae-4a4a-8549-0ec86410f58f").returns(package)
      get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"

      assert_response :success
      assert_template %w(katello/api/v2/packages/show)
    end

    def test_show_package_not_found
      Package.expects(:find).once.returns(nil)
      get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
      assert_response 404
    end

    def test_show_protected
      package = stub
      package.stubs(:repoids).returns([@repo.pulp_id])
      Package.stubs(:find).with("3805853f-5cae-4a4a-8549-0ec86410f58f").returns(package)

      assert_protected_action(:show, @read_permission, @unauth_permissions) do
        get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
      end
    end

  end
end
