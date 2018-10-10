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

      def event_data
        data = content['eventData']
        data ? JSON.parse(data) : {}
      end

      def status
        event_data['status']
      end

      def reasons
        event_data['reasons']
      end

      def compliant_role?
        reasons.none? { |reason| reason.match(/role/) }
      end

      def compliant_usage?
        reasons.none? { |reason| reason.match(/usage/) }
      end

      def compliant_addons?
        reasons.none? { |reason| reason.match(/add on/) }
      end

      def compliant_sla?
        reasons.none? { |reason| reason.match(/sla/) }
      end

      def consumer_uuid
        content['consumerUuid']
      end

      def pool_id
        if subject == 'pool.created' || subject == 'pool.deleted'
          content['entityId']
        elsif subject == 'entitlement.created' ||  subject == 'entitlement.deleted'
          content['referenceId']
        end
      end

      def pool
        Katello::Pool.find_by(:cp_id => pool_id)
      end

      def subscription_facet
        return nil if self.consumer_uuid.nil?
        ::Katello::Host::SubscriptionFacet.where(uuid: self.consumer_uuid).first
      end

      def create_pool_on_host
        return if self.subscription_facet.nil?
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).first_or_create
      end

      def remove_pool_from_host
        return if self.subscription_facet.nil? || pool.nil?
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).destroy_all
      end

      def import_pool(index_hosts = true)
        if pool
          ::Katello::EventQueue.push_event(::Katello::Events::ImportPool::EVENT_TYPE, pool.id)
        else
          ::Katello::Pool.import_pool(pool_id, index_hosts)
        end
      end
    end
  end
end
