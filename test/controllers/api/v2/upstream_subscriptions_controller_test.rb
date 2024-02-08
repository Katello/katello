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
      Katello::UpstreamConnectionChecker.any_instance.expects(:assert_connection)
    end

    def test_index
      params = { page: '3', per_page: '7', organization_id: @organization.id }
      UpstreamPool.expects(:fetch_pools).with({ 'page' => '3', 'per_page' => '7' }).returns(pools: [{}], total: nil)
      get :index, params: params

      assert_response :success
    end

    def test_index_full_result
      params = {full_result: 'true', page: '3', per_page: '7', organization_id: @organization.id}
      # omit page and per_page params for candlepin
      UpstreamPool.expects(:fetch_pools).with({}).returns({})

      get :index, params: params

      assert_response :success
    end

    def test_index_pool_ids
      params = {pool_ids: %w(1 2 3), page: '3', per_page: '7', organization_id: @organization.id}
      # omit page and per_page params for candlepin
      UpstreamPool.expects(:fetch_pools).with({ 'pool_ids' => %w(1 2 3) }).returns({})

      get :index, params: params

      assert_response :success
    end

    def test_index_no_per_page
      params = {page: '3', organization_id: @organization.id }
      UpstreamPool.expects(:fetch_pools).with({ 'page' => '3', 'per_page' => Setting[:entries_per_page] }).returns({})

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

    def test_destroy
      params = { pool_ids: %w(1 2 3), organization_id: @organization.id }
      assert_async_task ::Actions::Katello::UpstreamSubscriptions::RemoveEntitlements do |entitlement_ids|
        assert_equal entitlement_ids, %w(1 2 3)
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

    def test_update
      pools = [{"id" => "12345", "quantity" => 5}]

      assert_async_task ::Actions::Katello::UpstreamSubscriptions::UpdateEntitlements do |poolz|
        assert_equal poolz, pools
      end

      put :update, params: { organization_id: @organization.id, pools: pools }

      assert_response :success
    end

    def test_update_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:update, allowed_perms, denied_perms, [@organization]) do
        put :update, params: { organization_id: @organization.id, pools: [] }
      end
    end
  end
end
