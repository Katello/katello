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
  class Api::V2::SyncControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["Product"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @product = katello_products(:fedora)
      @repository = katello_repositories(:fedora_17_x86_64)
      @organization = get_organization
    end

    def permissions
      @sync_permission = :sync_products
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_index
      Product.any_instance.expects(:sync_status).returns([{}])

      get :index, :product_id => @product.cp_id, :organization_id => @organization.id
      assert_response :success
    end

    def test_index_product_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :product_id => @product.cp_id, :organization_id => @organization.id
      end
    end

    def test_index_repository_protected
      allowed_perms = [@sync_permission]
      denied_perms = []

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :repository_id => @repository.id
      end
    end

  end
end
