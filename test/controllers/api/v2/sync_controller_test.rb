# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SyncControllerTest < ActionController::TestCase
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
