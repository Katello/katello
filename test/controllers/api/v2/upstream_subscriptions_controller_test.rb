# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::UpstreamSubscriptionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
    end

    def permission
      :manage_subscription_allocations
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      models

      @organization.stubs(:owner_details)
        .returns("upstreamConsumer" => {'uuid' => '', 'idCert' => {'key' => '', 'cert' => ''}})
    end

    def test_index
      params = { page: '3', per_page: '7', organization_id: @organization.id }
      Api::V2::UpstreamSubscriptionsController.any_instance.stubs(:upstream_pool_params).returns(params)
      UpstreamPool.expects(:fetch_pools).with(params).returns(pools: [{}], total: nil)
      get :index, params: params

      assert_response :success
    end

    def test_index_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { organization_id: @organization.id }
      end
    end

    def test_index_disconnected
      Setting["content_disconnected"] = true
      get :index, params: { organization_id: @organization.id }
      assert_response :bad_request
    end

    def test_destroy
      params = { pool_ids: %w(1 2 3), organization_id: @organization.id }
      assert_async_task ::Actions::Katello::UpstreamSubscriptions::RemoveEntitlements do |entitlement_ids|
        entitlement_ids.must_equal %w(1 2 3)
      end

      delete :destroy, params: params

      assert_response :success
    end

    def test_create
      Katello::Resources::Candlepin::UpstreamConsumer.stubs(:bind_entitlements).returns({})
      pool_in = {id: '3', quantity: 6}
      params = { pools: [pool_in], organization_id: @organization.id }

      assert_async_task ::Actions::Katello::UpstreamSubscriptions::BindEntitlements do |pools|
        assert_equal(pools, [{'pool' => pool_in[:id], 'quantity' => pool_in[:quantity]}])
      end

      post :create, params: params

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@organization]) do
        delete :destroy, params: { pool_ids: [], organization_id: @organization.id }
      end
    end

    def test_create_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:create, allowed_perms, denied_perms, [@organization]) do
        post :create, params: { pools: [{"id" => "1234abcd", "quantity" => 3}],
                                organization_id: @organization.id }
      end
    end
  end
end
