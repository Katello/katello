require 'katello_test_helper'

module Katello
  class UpstreamConnectionCheckerTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
      @checker = Katello::UpstreamConnectionChecker.new(@organization)
    end

    def test_can_connect_ok
      @checker.expects(:assert_connection).returns(true)

      assert @checker.can_connect?
    end

    def test_can_connect_possible_exceptions
      Katello::UpstreamConnectionChecker::POSSIBLE_EXCEPTIONS.each do |exception_class|
        @checker.expects(:assert_connection).raises(exception_class)

        refute @checker.can_connect?
      end
    end

    def test_can_connect_unexpected_exception
      @checker.expects(:assert_connection).raises(StandardError)

      assert_raises(StandardError) do
        @checker.can_connect?
      end
    end

    def test_assert_all_good
      Katello::Resources::Candlepin::UpstreamConsumer.expects(:ping).returns
      @organization.expects(:manifest_expired?).returns(false)

      assert @checker.assert_connection
    end

    def test_assert_disconnected
      Setting[:subscription_connection_enabled] = false

      assert_raises Katello::Errors::SubscriptionConnectionNotEnabled do
        @checker.assert_connection
      end
    ensure
      Setting[:subscription_connection_enabled] = true
    end

    def test_assert_manifest_expired
      @organization.expects(:manifest_expired?).returns(true)

      assert_raises Katello::Errors::ManifestExpired do
        @checker.assert_connection
      end
    end

    def test_assert_upstream_ping
      @organization.expects(:manifest_expired?).returns(false)
      Katello::Resources::Candlepin::UpstreamConsumer.expects(:ping).raises(Katello::Errors::UpstreamConsumerGone)

      assert_raises Katello::Errors::UpstreamConsumerGone do
        @checker.assert_connection
      end
    end

    def test_assert_upstream_ping_with_not_found
      @organization.expects(:manifest_expired?).returns(false)
      Katello::Resources::Candlepin::UpstreamConsumer.expects(:ping).raises(Katello::Errors::UpstreamConsumerNotFound)

      assert_raises Katello::Errors::UpstreamConsumerNotFound do
        @checker.assert_connection
      end
    end
  end
end
