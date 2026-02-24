module Katello
  module Candlepin
    class MessageHandler
      # Service to handle parsing the messages we receive from candlepin
      attr_reader :subscription_facet, :message, :pool

      def initialize(message)
        @message = message
        @subscription_facet = ::Katello::Host::SubscriptionFacet.find_by_uuid(consumer_uuid) if consumer_uuid
        @pool = ::Katello::Pool.find_by_cp_id(pool_id) if pool_id
      end

      def subject
        @message.subject
      end

      def content
        @content ||= JSON.parse(message.content)
      end

      def event_data
        @event_data ||= (data = content['eventData']) ? JSON.parse(data) : {}
      end

      def entity_id
        content['entityId']
      end

      def target_name
        content['targetName']
      end

      def status
        event_data['status']
      end

      def reasons
        event_data['reasons']
      end

      def consumer_uuid
        content['consumerUuid']
      end

      def pool_id
        case subject
        when 'pool.created', 'pool.deleted'
          content['entityId']
        end
      end

      def import_pool
        if pool
          ::Katello::EventQueue.push_event(::Katello::Events::ImportPool::EVENT_TYPE, pool.id)
        else
          begin
            ::Katello::Pool.import_pool(pool_id)
          rescue ActiveRecord::RecordInvalid
            # if we hit this block it's likely that the pool's subscription, product are being created
            # as a result of manifest import/refresh or custom product creation
            Rails.logger.warn("Unable to import pool. It will likely be created by another process.")
          end
        end
      end
    end
  end
end
