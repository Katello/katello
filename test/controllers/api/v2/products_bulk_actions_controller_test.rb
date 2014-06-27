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
  class Api::V2::ProductsBulkActionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def self.before_suite
      disable_models = ["Product", "MarketingProduct", "Provider"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], disable_models, true)
      super
    end

    def models
      @organization = get_organization
      @products = Product.where(:id => katello_products(:empty_product, :empty_product_2).map(&:id))
      @provider = katello_providers(:fedora_hosted)
    end

    def permissions
      @view_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      User.current = User.find(users(:admin))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_destroy_products
      test_product = @products.first
      assert_async_task ::Actions::Katello::Product::Destroy do |product|
        test_product.id.must_equal product.id
      end

      put :destroy_products, {:ids => [test_product.cp_id], :organization_id => @organization.id}

      assert_response :success
    end

    def test_destroy_products_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@update_permission, @create_permission, @sync_permission, @view_permission]

      assert_protected_action(:destroy_products, allowed_perms, denied_perms) do
        put :destroy_products, {:ids => @products.collect(&:cp_id), :organization_id => @organization.id}
      end
    end

    def test_sync
      Product.any_instance.expects(:sync).times(@products.length).returns([{}])

      put :sync_products, {:ids => @products.collect(&:cp_id), :organization_id => @organization.id}

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@update_permission, @destroy_permission, @view_permission, @create_permission]

      assert_protected_action(:sync_products, allowed_perms, denied_perms) do
        put :sync_products, {:ids => @products.collect(&:cp_id), :organization_id => @organization.id}
      end
    end

    def test_update_sync_plans
      Product.any_instance.expects(:save!).times(@products.length).returns([{}])

      put :update_sync_plans, {:ids => @products.collect(&:cp_id), :organization_id => @organization.id, :plan_id => 1}

      assert_response :success
    end

    def test_update_sync_plans_protected
      allowed_perms = [@update_permission]
      denied_perms = [@sync_permission, @create_permission, @destroy_permission, @view_permission]

      assert_protected_action(:update_sync_plans, allowed_perms, denied_perms) do
        put :update_sync_plans, {:ids => @products.collect(&:cp_id), :organization_id => @organization.id}
      end
    end
  end
end
