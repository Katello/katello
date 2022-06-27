require 'katello_test_helper'

module Katello
  module Service
    class CandlepinConsumerTestBase < ActiveSupport::TestCase
      include VCR::TestCase

      def setup
        set_user
      end
    end

    class CandlepinConsumer < CandlepinConsumerTestBase
      ENTITLEMENT_A = {'pool' => {'id' => 1}, 'quantity' => 1}.freeze
      ENTITLEMENT_B = {'pool' => {'id' => 1}, 'quantity' => 1}.freeze
      ENTITLEMENT_C = {'pool' => {'id' => 1}, 'quantity' => 3}.freeze
      ENTITLEMENT_D = {'pool' => {'id' => 2}, 'quantity' => 1}.freeze
      ENTITLEMENTS = [ENTITLEMENT_A, ENTITLEMENT_B, ENTITLEMENT_C, ENTITLEMENT_D].freeze

      def setup
        super
        Katello::Candlepin::Consumer.any_instance.stubs(:entitlements).returns(ENTITLEMENTS)
        @consumer = Katello::Candlepin::Consumer.new('foo', 'org_label')
      end

      def test_filter_entitlements_simple
        assert_equal ENTITLEMENTS, @consumer.filter_entitlements
        assert_equal [ENTITLEMENT_A], @consumer.filter_entitlements(1, [1])
        assert_equal [], @consumer.filter_entitlements(1, [7])
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_B, ENTITLEMENT_C], @consumer.filter_entitlements(1, [])
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_B, ENTITLEMENT_C], @consumer.filter_entitlements(1, nil)
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_B], @consumer.filter_entitlements(1, [1, 1])
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_C], @consumer.filter_entitlements(1, [1, 3])
        assert_equal [ENTITLEMENT_A, ENTITLEMENT_B, ENTITLEMENT_C], @consumer.filter_entitlements(1)
      end

      def test_compliance_reasons
        reasons = [{"key" => "NOTCOVERED", "message" => "Not supported by a valid subscription.", "attributes" => {"product_id" => "69", "name" => "Red Hat Server"}}]
        Resources::Candlepin::Consumer.stubs(:compliance).returns('reasons' => reasons)

        assert_equal ["Red Hat Server: Not supported by a valid subscription."], @consumer.compliance_reasons
      end

      def test_distribution_to_puppet_os
        assert_equal 'RedHat', Candlepin::Consumer.distribution_to_puppet_os('Red Hat Enterprise Linux Server')
        assert_equal 'RedHat', Candlepin::Consumer.distribution_to_puppet_os('Red Hat Enterprise Linux Desktop')
        assert_equal 'RedHat', Candlepin::Consumer.distribution_to_puppet_os('Redhat')
        assert_equal 'RedHat', Candlepin::Consumer.distribution_to_puppet_os('something Red hat')

        assert_equal 'Fedora', Candlepin::Consumer.distribution_to_puppet_os('Fedora')
        assert_equal 'Fedora', Candlepin::Consumer.distribution_to_puppet_os('fedora')

        assert_equal 'CentOS', Candlepin::Consumer.distribution_to_puppet_os('CentOS')
        assert_equal 'CentOS', Candlepin::Consumer.distribution_to_puppet_os('centosGood')

        assert_equal 'SLES', Candlepin::Consumer.distribution_to_puppet_os('SLES')
        assert_equal 'SLES', Candlepin::Consumer.distribution_to_puppet_os('SUSE Linux Enterprise Server')

        assert_equal 'Ubuntu', Candlepin::Consumer.distribution_to_puppet_os('Ubuntu')
        assert_equal 'Debian', Candlepin::Consumer.distribution_to_puppet_os('Debian')

        assert_equal 'OracleLinux', Candlepin::Consumer.distribution_to_puppet_os('Oracle Linux Server')

        assert_equal 'AlmaLinux', Candlepin::Consumer.distribution_to_puppet_os('AlmaLinux')

        assert_equal 'Rocky', Candlepin::Consumer.distribution_to_puppet_os('Rocky Linux')

        assert_equal 'Amazon', Candlepin::Consumer.distribution_to_puppet_os('Amazon')

        assert_equal 'Unknown', Candlepin::Consumer.distribution_to_puppet_os('RedHot')
      end

      def test_virtual_guests
        hosts = [hosts(:one), hosts(:two)]
        guest_uuids = hosts.map { |host| { 'uuid' => host.subscription_facet.uuid } }

        Resources::Candlepin::Consumer.expects(:virtual_guests).once.returns(guest_uuids)

        assert_equal hosts, @consumer.virtual_guests.sort
        assert_equal hosts, @consumer.virtual_guests.sort
      end
    end
  end
end
