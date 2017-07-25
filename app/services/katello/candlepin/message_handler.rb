module Katello
  module Candlepin
    class MessageHandler
      # Service to handle parsing the messages we receive from candlepin
      attr_accessor :message

      def initialize(message)
        @message = message
      end

      def subject
        @message.subject
      end

      def content
        JSON.parse(@message.content)
      end

      def reference_id
        self.content['referenceId']
      end

      def entity_id
        self.content['entityId']
      end

      def new_entity
        self.content['newEntity']
      end

      def old_entity
        self.content['oldEntity']
      end

      def sub_status
        if self.new_entity
          parsed = JSON.parse(self.new_entity)
          parsed['status']['status']
        end
      end

      def consumer_uuid
        entity = self.new_entity || self.old_entity
        if entity
          parsed = JSON.parse(entity)
          parsed['consumer']['uuid']
        end
      end

      def subscription_facet
        ::Katello::Host::SubscriptionFacet.where(uuid: self.consumer_uuid).first
      end

      def create_pool_on_host
        pool = self.pool_by_reference_id
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).first_or_create
      end

      def remove_pool_from_host
        pool = self.pool_by_reference_id
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).destroy_all
      end

      def import_pool(pool_id, index_hosts = true)
        pool = ::Katello::Pool.find_by(:cp_id => pool_id)
        if pool
          ::Katello::EventQueue.push_event(::Katello::Events::ImportPool::EVENT_TYPE, pool.id)
        else
          ::Katello::Pool.import_pool(pool_id, index_hosts)
        end
      end

      def pool_by_reference_id
        ::Katello::Pool.where(:cp_id => self.reference_id).first
      end

      def import_pool_by_reference_id
        self.import_pool(self.reference_id, false)
      end

      def import_pool_by_entity_id
        self.import_pool(self.entity_id, false)
      end
    end
  end
end
