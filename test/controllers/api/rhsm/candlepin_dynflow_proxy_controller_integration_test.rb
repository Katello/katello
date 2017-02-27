# encoding: utf-8
require "katello_test_helper"

module Katello
  # In order to test rack middleware, this test must inherit ActionDispatch::IntegrationTest
  class Api::Rhsm::CandlepinDynflowProxyControllerIntegrationTest < ActionDispatch::IntegrationTest
    before do
      @content_view = katello_content_views(:acme_default)
      @environment = katello_environments(:library)

      @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @environment, :organization => @content_view.organization)
    end

    test 'params are not parsed in the controller' do
      JSON.expects(:parse).never
      Api::Rhsm::CandlepinDynflowProxyController.any_instance.expects(:async_task).returns(nil)
      Resources::Candlepin::Consumer.expects(:get).returns({})

      put "/rhsm/consumers/#{@host.subscription_facet.uuid}/packages", {}.to_json, 'CONTENT_TYPE' => 'application/json'

      assert_response :success
    end
  end
end
