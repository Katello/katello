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
            'key' => @org.label,
          },
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
