require 'katello_test_helper'

module Katello
  class SubscriptionFacetHostExtensionsTest
    class UpdateCandlepinAssociationsTest < ActiveSupport::TestCase
      test "doesn't update candlepin if subscription facet was destroyed" do
        host = FactoryBot.build_stubbed(:host, :with_content, :with_subscription)
        host.content_facet.stubs(:save!)
        host.subscription_facet.expects(:destroyed?).once.returns(true)
        ::Katello::Resources::Candlepin::Consumer.expects(:update).never

        host.update_candlepin_associations
      end

      test "raises RuntimeError if consumer is gone" do
        host = FactoryBot.build_stubbed(:host, :with_content, :with_subscription)
        ::Katello::Resources::Candlepin::Consumer.expects(:update).raises(RestClient::Gone)
        host.content_facet.stubs(:save!)

        assert_raises(RuntimeError, /missing or deleted/) do
          host.update_candlepin_associations
        end
      end
    end
  end
end
