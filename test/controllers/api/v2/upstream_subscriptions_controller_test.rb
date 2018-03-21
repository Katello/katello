# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::UpstreamSubscriptionsControllerTest < ActionController::TestCase
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
      params = { page: '3', per_page: '7' }
      Api::V2::UpstreamSubscriptionsController.any_instance.stubs(:upstream_pool_params).returns(params)
      UpstreamPool.expects(:fetch_pools).with(params).returns([{}])
      get :index, params: params

      assert_response :success
    end

    def test_index_protected
      allowed_perms = [permission]
      denied_perms = []

      assert_protected_action(:index, allowed_perms, denied_perms, []) do
        get :index, params: { }
      end
    end

    def test_index_disconnected
      Setting["content_disconnected"] = true
      get :index, params: { organization_id: @organization.id }
      assert_response :bad_request
    end
  end
end
