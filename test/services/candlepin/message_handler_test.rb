require 'katello_test_helper'

module Katello
  class MessageHandlerTestBase < ActiveSupport::TestCase
    let(:handler) { ::Katello::Candlepin::MessageHandler.new(@event) }

    def setup
      json = File.read("#{Katello::Engine.root}/test/fixtures/candlepin_messages/#{event_name}.json")
      @event = OpenStruct.new(subject: event_name, content: json)
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

  class ComplianceCreatedTest < MessageHandlerTestBase
    let(:event_name) { 'compliance.created' }

    def test_consumer_uuid
      assert_equal @consumer_uuid, handler.consumer_uuid
    end

    def test_reasons
      assert_equal 1, handler.reasons.count
      assert_equal 'Red Hat Enterprise Linux Server', handler.reasons[0]['productName']
    end

    def test_status
      assert_equal 'invalid', handler.status
    end

    def test_subscription_facet
      assert_equal @facet, handler.subscription_facet
    end
  end

  class EntitlementCreatedTest < MessageHandlerTestBase
    let(:event_name) { 'entitlement.created' }

    def test_pool_id
      assert_equal @pool_id, handler.pool_id
    end

    def test_consumer_uuid
      assert_equal @consumer_uuid, handler.consumer_uuid
    end

    def test_create_pool_on_host
      @facet.pools = []

      handler.create_pool_on_host
      refute_empty @facet.pools.where(:cp_id => @pool_id)
    end
  end

  class EntitlementDeletedTest < MessageHandlerTestBase
    let(:event_name) { 'entitlement.deleted' }

    def test_consumer_uuid
      assert_equal @consumer_uuid, handler.consumer_uuid
    end

    def test_pool_id
      assert_equal @pool_id, handler.pool_id
    end

    def test_remove_pool_from_host
      @facet.pools = [@pool]
      handler.remove_pool_from_host
      assert_empty @facet.pools.where(:cp_id => @pool_id)
    end
  end

  class PoolCreatedTest < MessageHandlerTestBase
    let(:event_name) { 'pool.created' }

    def test_pool_id
      assert_equal @pool_id, handler.pool_id
    end

    def test_import_pool
      Katello::EventQueue.expects(:push_event).with('import_pool', @pool.id)

      handler.import_pool
    end
  end

  class PoolDeletedTest < MessageHandlerTestBase
    let(:event_name) { 'pool.deleted' }

    def test_pool_id
      assert_equal @pool_id, handler.pool_id
    end

    def test_delete_pool
      handler.delete_pool
      assert_empty Katello::Pool.find_by(:cp_id => @pool_id)
    end

    def test_delete_pool_on_null
      pool = handler.pool
      handler.stubs(:pool).returns(pool).then.returns(nil)
      # assert no errors are raised
      handler.delete_pool
      assert_empty Katello::Pool.find_by(:cp_id => @pool_id)
    end
  end

  class OwnerContentAccessModeModifiedTest < MessageHandlerTestBase
    let(:event_name) { 'owner_content_access_mode.modified' }

    def setup
      @org = get_organization(:empty_organization)
      Katello::Resources::Candlepin::Owner.expects(:all).returns(
        [
          {
            'displayName' => @org.name,
            'key' => @org.label
          }
        ]
      )
      super
    end

    def test_content_access_mode_modified
      Organization.any_instance.expects(:simple_content_access?).with(cached: false)
      Rails.logger.expects(:error).with("Received content_access_mode_modified event for org #{@org.label}. This event is no longer supported.")

      handler.handle_content_access_mode_modified
    end
  end
end
