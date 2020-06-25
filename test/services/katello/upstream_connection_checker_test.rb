require 'katello_test_helper'

module Katello
  class UpstreamConnectionCheckerTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
      @checker = Katello::UpstreamConnectionChecker.new(@organization)
    end

    def test_all_good
      Katello::Resources::Candlepin::UpstreamConsumer.expects(:ping).returns
      @organization.expects(:manifest_expired?).returns(false)

      assert @checker.assert_connection
    end

    def test_disconnected
      Setting[:content_disconnected] = true

      assert_raises Katello::Errors::DisconnectedMode do
        @checker.assert_connection
      end
    ensure
      Setting[:content_disconnected] = false
    end

    def test_manifest_expired
      @organization.expects(:manifest_expired?).returns(true)

      assert_raises Katello::Errors::ManifestExpired do
        @checker.assert_connection
      end
    end

    def test_upstream_ping
      @organization.expects(:manifest_expired?).returns(false)
      Katello::Resources::Candlepin::UpstreamConsumer.expects(:ping).raises(Katello::Errors::UpstreamConsumerGone)

      assert_raises Katello::Errors::UpstreamConsumerGone do
        @checker.assert_connection
      end
    end
  end
end
