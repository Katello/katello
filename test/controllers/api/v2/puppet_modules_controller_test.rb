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
  class Api::V2::PuppetModulesControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["Organization", "KTEnvironment", "Repository", "Product", "Provider"]
      services = ["Candlepin", "Pulp", "ElasticSearch"]
      disable_glue_layers(services, models)
      super
    end

    def models
      @library = katello_environments(:library)
      @repo = Repository.find(katello_repositories(:p_forge))
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products

      @auth_permissions = [@read_permission, :view_content_views]
      @unauth_permissions = [@create_permission, @update_permission, @destroy_permission, @sync_permission]
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
      [:package_group_count, :package_count, :puppet_module_count].each do |content_type_count|
        Repository.any_instance.stubs(content_type_count).returns(0)
      end
    end

    def test_index_by_env
      get :index, :environment_id => @library.id

      assert_response :success
      assert_template %w(katello/api/v2/puppet_modules/index)
    end

    def test_index_by_repo
      get :index, :repository_id => @repo.id

      assert_response :success
      assert_template %w(katello/api/v2/puppet_modules/index)
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by_id => environment))

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template %w(katello/api/v2/puppet_modules/index)
    end

    def test_index_protected
      assert_protected_action(:index, @read_permission, @unauth_permissions) do
        get :index, :repository_id => @repo.id
      end
    end

    def test_show
      PuppetModule.expects(:find).once.returns(PuppetModule.new(:repoids => [@repo.pulp_id]))
      get :show, :repository_id => @repo.id, :id => "abc-123"

      assert_response :success
      assert_template %w(katello/api/v2/puppet_modules/show)
    end

    def test_show_protected
      puppet_module = stub
      puppet_module.stubs(:repoids).returns([@repo.pulp_id])
      PuppetModule.stubs(:find).with("abc-123").returns(puppet_module)

      assert_protected_action(:show, @read_permission, @unauth_permissions) do
        get :show, :repository_id => @repo.id, :id => "abc-123"
      end
    end

    def test_show_module_not_in_repo
      PuppetModule.expects(:find).once.returns(mock(:repoids => ['uh-oh']))
      get :show, :repository_id => @repo.id, :id => "abc-123"
      assert_response 404
    end

    def test_show_module_not_found
      PuppetModule.expects(:find).once.returns(nil)
      get :show, :repository_id => @repo.id, :id => "abc-123"
      assert_response 404
    end

  end
end
