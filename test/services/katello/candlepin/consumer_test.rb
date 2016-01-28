require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class CandlepinConsumerTestBase < ActiveSupport::TestCase
      def setup
        User.current = User.find(FIXTURES['users']['admin']['id'])

        VCR.insert_cassette('services/candlepin/consumer')
      end

      def teardown
        VCR.eject_cassette
      end
    end

    class CandlepinConsumer < CandlepinConsumerTestBase
      ENTITLEMENT_A = {'pool' => {'id' => 1}, 'quantity' => 1}
      ENTITLEMENT_B = {'pool' => {'id' => 1}, 'quantity' => 1}
      ENTITLEMENT_C = {'pool' => {'id' => 1}, 'quantity' => 3}
      ENTITLEMENT_D = {'pool' => {'id' => 2}, 'quantity' => 1}
      ENTITLEMENTS = [ENTITLEMENT_A, ENTITLEMENT_B, ENTITLEMENT_C, ENTITLEMENT_D]

      def setup
        super
        Katello::Candlepin::Consumer.any_instance.stubs(:entitlements).returns(ENTITLEMENTS)
        @consumer = Katello::Candlepin::Consumer.new('foo')
      end

      def test_filter_entitlements_simple
        assert_equal ENTITLEMENTS, @consumer.filter_entitlements
        assert_equal [ENTITLEMENT_A], @consumer.filter_entitlements(1, [1])
        assert_equal [], @consumer.filter_entitlements(1, [7])
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_B, ENTITLEMENT_C], @consumer.filter_entitlements(1, [])
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_B, ENTITLEMENT_C], @consumer.filter_entitlements(1, nil)
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_B], @consumer.filter_entitlements(1, [1, 1])
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_C], @consumer.filter_entitlements(1, [1, 3])
      end

      def test_compliance_reasons
        reasons = [{"key"=>"NOTCOVERED", "message"=>"Not supported by a valid subscription.", "attributes"=>{"product_id"=>"69", "name"=>"Red Hat Server"}}]
        Resources::Candlepin::Consumer.stubs(:compliance).returns('reasons' => reasons)

        assert_equal ["Red Hat Server: Not supported by a valid subscription."], @consumer.compliance_reasons
      end
    end
  end
end
