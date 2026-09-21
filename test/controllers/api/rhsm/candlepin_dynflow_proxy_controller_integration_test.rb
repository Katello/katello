# encoding: utf-8

require "katello_test_helper"

module Katello
  # In order to test rack middleware, this test must inherit ActionDispatch::IntegrationTest
  class Api::Rhsm::CandlepinDynflowProxyControllerIntegrationTest < ActionDispatch::IntegrationTest
    self.fixture_path = ActiveSupport::TestCase.fixture_path

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

    test 'uploads RPM profiles with association IDs above the integer limit' do
      Resources::Candlepin::Consumer.expects(:get).times(3).returns({})
      stub_organization_creator
      connection = ActiveRecord::Base.connection
      sequence = connection.default_sequence_name(:katello_host_installed_packages)
      # RESTART is rolled back with the fixture transaction, unlike setval.
      connection.execute("ALTER SEQUENCE #{sequence} RESTART WITH 2147483647")
      packages = [{"name" => "bigint-test", "version" => "1", "release" => "1", "arch" => "noarch"}]
      profiles = [{"content_type" => "rpm", "profile" => packages}]
      headers = {
        'CONTENT_TYPE' => 'application/json',
        'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(users(:apiadmin).login, 'secret'),
      }

      # Cross the boundary with a package update, then repeat the same profile.
      [['1', 2_147_483_647], ['2', 2_147_483_648], ['2', 2_147_483_648]].each do |version, expected_id|
        packages.first['version'] = version
        put "/rhsm/consumers/#{@host.subscription_facet.uuid}/profiles", params: profiles.to_json, headers: headers

        assert_response :success
        assert_equal 1, @host.host_installed_packages.count
        assert_equal expected_id, @host.host_installed_packages.first.id
      end
    end
  end
end
