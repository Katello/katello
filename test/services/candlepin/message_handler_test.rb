require 'katello_test_helper'

module Katello
  class MessageHandlerTest < ActiveSupport::TestCase
    def setup
      @entitlement_created = File.read("#{Katello::Engine.root}/test/fixtures/files/entitlement_created.txt")
      @entitlement_created_json = JSON.parse(@entitlement_created)
      raw_message = Actions::Candlepin::ListenOnCandlepinEvents::Event.new(
                      message_id: "foo",
                      subject: "foo",
                      content: @entitlement_created)
      @message_handler = ::Katello::Candlepin::MessageHandler.new(raw_message)
      @pool = katello_pools(:pool_one)
    end

    def test_content
      @message_handler.content == @entitlement_created
    end

    def test_reference_id
      @message_handler.reference_id == @entitlement_created_json['referenceId']
    end

    def test_entity_id
      @message_handler.entity_id == @entitlement_created_json['entityId']
    end

    def test_new_entity
      @message_handler.new_entity == @entitlement_created_json['newEntity']
    end

    def test_old_entity
      @message_handler.old_entity == @entitlement_created_json['oldEntity']
    end

    def test_consumer_uuid
      consumer_uuid = JSON.parse(@entitlement_created_json['newEntity'])['consumer']['uuid']
      assert @message_handler.consumer_uuid == consumer_uuid
    end

    def test_subscription_facet
      consumer_uuid = JSON.parse(@entitlement_created_json['newEntity'])['consumer']['uuid']
      sub_facet = ::Katello::Host::SubscriptionFacet.create(uuid: consumer_uuid)
      @message_handler.subscription_facet == sub_facet
    end

    def test_create_pool_on_host
      @message_handler.expects(:subscription_facet).returns(::Katello::Host::SubscriptionFacet.first).at_least_once
      @message_handler.expects(:reference_id).returns(@pool.cp_id).at_least_once

      @message_handler.create_pool_on_host
      assert ::Katello::SubscriptionFacetPool.where(subscription_facet_id: @message_handler.subscription_facet.id,
                                                    pool_id: @pool.id).count > 0

      @message_handler.remove_pool_from_host
      assert ::Katello::SubscriptionFacetPool.where(subscription_facet_id: @message_handler.subscription_facet.id,
                                                    pool_id: @pool.id).count == 0
    end

    def test_import_pool
      pool = ::Katello::Pool.first
      ::Katello::Pool.expects(:import_pool).with(pool.id, true).returns(true).once

      @message_handler.import_pool(pool.id)
    end
  end
end
