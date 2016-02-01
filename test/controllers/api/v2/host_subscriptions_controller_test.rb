# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostSubscriptionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    tests Katello::Api::V2::HostSubscriptionsController

    def models
      @host = FactoryGirl.create(:host, :with_subscription)
      @pool = katello_pools(:pool_one)
      @entitlements = [{:pool => {:id => @pool.cp_id}, :quantity => '3'}.with_indifferent_access]
    end

    def permissions
      @view_permission = :view_hosts
      @create_permission = :create_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def backend_stubs
      Katello::Pool.any_instance.stubs(:pool_facts).returns({})
      Katello::Candlepin::Consumer.any_instance.stubs(:entitlements).returns(@entitlements)
    end

    def setup
      setup_controller_defaults_api
      setup_foreman_routes
      login_user(users(:admin))

      models
      backend_stubs
      permissions
    end

    def test_index
      get :index, :host_id => @host.id

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_index_bad_system
      @host = FactoryGirl.create(:host)

      get :index, :host_id => @host.id

      assert_response 400
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :host_id => @host.id
      end
    end

    def test_auto_attach
      assert_sync_task(::Actions::Katello::Host::AutoAttachSubscriptions, @host)
      put :auto_attach, :host_id => @host.id

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_auto_attach_protected
      allowed_perms = [@update_permission]
      denied_perms = [@create_permission, @view_permission, @destroy_permission]

      assert_protected_action(:auto_attach, allowed_perms, denied_perms) do
        put :auto_attach, :host_id => @host.id
      end
    end

    def test_add_subscriptions
      assert_sync_task(::Actions::Katello::Host::AttachSubscriptions) do |host, pools_with_quantities|
        assert_equal @host, host
        assert_equal 1, pools_with_quantities.count
        assert_equal @pool, pools_with_quantities[0].pool
        assert_equal ["1"], pools_with_quantities[0].quantities
      end

      post :add_subscriptions, :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => 1}]

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_add_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:add_subscriptions, allowed_perms, denied_perms) do
        post :add_subscriptions, :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => 1}]
      end
    end

    def test_remove_subscriptions
      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Host::RemoveSubscriptions, @host, @entitlements)

      post :remove_subscriptions, :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => 3}]

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_remove_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:remove_subscriptions, allowed_perms, denied_perms) do
        post :remove_subscriptions, :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => 3}]
      end
    end
  end
end
