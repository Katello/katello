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
  class Api::V2::DistributionsControllerTest < ActionController::TestCase

    def before_suite
      models = ["Organization", "KTEnvironment", "Distribution", "Repository", "Product"]
      services = ["Candlepin", "Pulp", "ElasticSearch"]
      disable_glue_layers(services, models)
      super
    end

    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64_dev))
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
      assert_template %w(katello/api/v2/distributions/index)
    end

    def test_index_protected
      assert_protected_action(:index, @read_permission, @unauth_permissions) do
        get :index, :repository_id => @repo.id
      end
    end

    def test_show
      distribution = stub
      distribution.stubs(:repoids).returns([@repo.pulp_id])
      distribution.stubs(:files).returns({})
      Distribution.expects(:find).once.with("ks-Test Family-TestVariant-16-x86_64").returns(distribution)
      get :show, :repository_id => @repo.id, :id => "ks-Test Family-TestVariant-16-x86_64"

      assert_response :success
      assert_template %w(katello/api/v2/distributions/show)
    end

    def test_show_not_found
      Distribution.expects(:find).once.returns(nil)
      get :show, :repository_id => @repo.id, :id => "ks-Test Family-TestVariant-16-x86_64"
      assert_response 404
    end

    def test_show_protected
      distribution = stub
      distribution.stubs(:repoids).returns([@repo.pulp_id])
      Distribution.stubs(:find).with("ks-Test Family-TestVariant-16-x86_64").returns(distribution)

      assert_protected_action(:show, @read_permission, @unauth_permissions) do
        get :show, :repository_id => @repo.id, :id => "ks-Test Family-TestVariant-16-x86_64"
      end
    end

  end
end
