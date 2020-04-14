require 'katello_test_helper'

module Katello
  class MessageHandlerTestBase < ActiveSupport::TestCase
    def load_handler(event_name)
      json = File.read("#{Katello::Engine.root}/test/fixtures/candlepin_messages/#{event_name}.json")
      event = OpenStruct.new(subject: event_name, content: json)
      ::Katello::Candlepin::MessageHandler.new(event)
    end

    def setup
      @pool = katello_pools(:pool_one)

      #from json files
      @consumer_uuid = 'e930c61b-8dcb-4bca-8282-a8248185f9af'
      @pool_id = '4028f95162acf5c20162b043b1c606ca'

      @pool = katello_pools(:pool_one)
      @pool.update!(:cp_id => @pool_id)

      @facet = katello_subscription_facets(:one)
      @facet.update!(:uuid => @consumer_uuid)
    end
  end

  class SystemPurposeComplianceCreatedTest < MessageHandlerTestBase
    def setup
      super
      @handler = load_handler('system_purpose_compliance.created')
    end

    def test_system_purpose
      assert_equal @handler.system_purpose.overall_status, :mismatched
      assert_equal @handler.system_purpose.sla_status, :mismatched
      assert_equal @handler.system_purpose.role_status, :not_specified
      assert_equal @handler.system_purpose.usage_status, :not_specified
      assert_equal @handler.system_purpose.addons_status, :not_specified
    end
  end

  class ComplianceCreatedTest < MessageHandlerTestBase
    def setup
      super
      @handler = load_handler('compliance.created')
    end

    def test_consumer_uuid
      assert_equal @consumer_uuid, @handler.consumer_uuid
    end

    def test_reasons
      assert_equal 1, @handler.reasons.count
      assert_equal 'Red Hat Enterprise Linux Server', @handler.reasons[0]['productName']
    end

    def test_status
      assert_equal 'invalid', @handler.status
    end

    def test_subscription_facet
      assert_equal @facet, @handler.subscription_facet
    end
  end

  class EntitlementCreated < MessageHandlerTestBase
    def setup
      super
      @handler = load_handler('entitlement.created')
    end

    def test_pool_id
      assert_equal @pool_id, @handler.pool_id
    end

    def test_consumer_uuid
      assert_equal @consumer_uuid, @handler.consumer_uuid
    end

    def test_create_pool_on_host
      @facet.pools = []

      @handler.create_pool_on_host
      refute_empty @facet.pools.where(:cp_id => @pool_id)
    end
  end

  class EntitlementDeleted < MessageHandlerTestBase
    def setup
      super
      @handler = load_handler('entitlement.deleted')
    end

    def test_consumer_uuid
      assert_equal @consumer_uuid, @handler.consumer_uuid
    end

    def test_pool_id
      assert_equal @pool_id, @handler.pool_id
    end

    def test_remove_pool_from_host
      @facet.pools = [@pool]
      @handler.remove_pool_from_host
      assert_empty @facet.pools.where(:cp_id => @pool_id)
    end
  end

  class PoolCreated < MessageHandlerTestBase
    def setup
      super
      @handler = load_handler('pool.created')
    end

    def test_pool_id
      assert_equal @pool_id, @handler.pool_id
    end

    def test_import_pool
      Katello::EventQueue.expects(:push_event).with('import_pool', @pool.id)

      @handler.import_pool
    end
  end

  class PoolDeleted < MessageHandlerTestBase
    def setup
      super
      @handler = load_handler('pool.deleted')
    end

    def test_pool_id
      assert_equal @pool_id, @handler.pool_id
    end

    def test_delete_pool
      @handler.delete_pool
      assert_empty Katello::Pool.find_by(:cp_id => @pool_id)
    end
  end
end
