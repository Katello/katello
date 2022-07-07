# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SimpleContentAccessControllerTest < ActionController::TestCase
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

    def test_enable_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:enable, allowed_perms, denied_perms, [@organization]) do
        post :enable, params: { organization_id: @organization.id }
      end
    end

    def test_enable_success
      Katello::Resources::Candlepin::UpstreamConsumer.stubs(:update).returns({})

      assert_async_task(::Actions::Katello::Organization::SimpleContentAccess::Enable) do |organization_id|
        org = Organization.find(organization_id)
        assert_equal @organization, org
      end

      put :enable, params: { organization_id: @organization.id }

      assert_response :success
    end

    def test_disable_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:disable, allowed_perms, denied_perms, [@organization]) do
        post :disable, params: { organization_id: @organization.id }
      end
    end

    def test_disable_success
      Katello::Resources::Candlepin::UpstreamConsumer.stubs(:update).returns({})

      assert_async_task(::Actions::Katello::Organization::SimpleContentAccess::Disable) do |organization_id|
        org = Organization.find(organization_id)
        assert_equal @organization, org
      end

      put :disable, params: { organization_id: @organization.id }

      assert_response :success
    end

    def test_eligible_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:eligible, allowed_perms, denied_perms, [@organization]) do
        post :eligible, params: { organization_id: @organization.id }
      end
    end

    def test_status_true
      Organization.any_instance.stubs(:simple_content_access?).returns(true)

      get :status, params: { organization_id: @organization.id }
      body = JSON.parse(response.body)

      assert_response :success
      assert(body['simple_content_access'])
    end

    def test_status_false
      Organization.any_instance.stubs(:simple_content_access?).returns(false)

      get :status, params: { organization_id: @organization.id }
      body = JSON.parse(response.body)

      assert_response :success
      refute(body['simple_content_access'])
    end

    def test_status_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:status, allowed_perms, denied_perms, [@organization]) do
        get :status, params: { organization_id: @organization.id }
      end
    end

    def test_eligible
      Katello::Candlepin::UpstreamConsumer.any_instance.expects(:simple_content_access_eligible?).returns(true)

      get :eligible, params: { organization_id: @organization.id }

      assert_response :success
    end
  end
end
