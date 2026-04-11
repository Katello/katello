# encoding: utf-8

require "katello_test_helper"

module Katello
  # In order to test rack middleware, this test must inherit ActionDispatch::IntegrationTest
  class Api::Rhsm::CandlepinDynflowProxyControllerIntegrationTest < ActionDispatch::IntegrationTest
    before do
      @content_view = katello_content_views(:acme_default)
      @environment = katello_environments(:library)

      @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @environment, :organization => @content_view.organization)
    end

    test 'params are not parsed in the controller' do
      Resources::Candlepin::Consumer.expects(:get).returns({})
      stub_organization_creator
      packages = [{"vendor" => "CentOS", "name" => "python-six", "epoch" => 0, "version" => "1.9.0", "release" => "2.el7", "arch" => "noarch"}]

      put "/rhsm/consumers/#{@host.subscription_facet.uuid}/packages", params: packages.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }

      assert_nil request.params['_json']
      assert_equal 'text/plain', request.headers['CONTENT_TYPE']
      assert_response :success
    end
  end
end
