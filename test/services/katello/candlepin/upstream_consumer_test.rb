require 'katello_test_helper'

module Katello
  module Candlepin
    class UpstreamConsumerTest < ActiveSupport::TestCase
      def setup
        @organization = get_organization
        @upstream_consumer = Katello::Candlepin::UpstreamConsumer.new(@organization)
      end

      def test_simple_content_access_eligible_not_implemented
        Katello::Resources::Candlepin::UpstreamConsumer.expects(:content_access).returns({})

        assert @upstream_consumer.simple_content_access_eligible?
      end

      def test_simple_content_access_eligible_ineligible
        Katello::Resources::Candlepin::UpstreamConsumer.expects(:content_access).returns({ contentAccessModeList: %w(entitlement) })

        refute @upstream_consumer.simple_content_access_eligible?
      end

      def test_simple_content_access_eligible_eligible
        Katello::Resources::Candlepin::UpstreamConsumer.expects(:content_access).returns({ contentAccessModeList: %w(entitlement org_environment) })

        assert @upstream_consumer.simple_content_access_eligible?
      end
    end
  end
end
