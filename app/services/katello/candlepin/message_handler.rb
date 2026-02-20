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

      def delete_pool
        if Katello::Pool.where(:cp_id => pool_id).destroy_all.any?
          Rails.logger.info "Deleted Katello::Pool with cp_id=#{pool_id}"
        end
      end
    end
  end
end
