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
        @content ||= JSON.parse(message.content)
      end

      def event_data
        @event_data ||= (data = content['eventData']) ? JSON.parse(data) : {}
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

      def system_purpose
        if subject == 'system_purpose_compliance.created' && @system_purpose.nil?
          @system_purpose = Katello::Candlepin::SystemPurpose.new(event_data)
        end
        @system_purpose
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
        old_host_ids = pool.subscription_facets.pluck(:host_id)
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).first_or_create
        pool.import_audit_record(old_host_ids)
      end

      def remove_pool_from_host
        return if self.subscription_facet.nil? || pool.nil?
        old_host_ids = pool.subscription_facets.pluck(:host_id)
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).destroy_all
        pool.import_audit_record(old_host_ids)
      end

      def import_pool(index_hosts = true)
        if pool
          ::Katello::EventQueue.push_event(::Katello::Events::ImportPool::EVENT_TYPE, pool.id)
        else
          ::Katello::Pool.import_pool(pool_id, index_hosts)
        end
      end

      def delete_pool
        if Katello::Pool.where(:cp_id => pool_id).destroy_all.any?
          Rails.logger.info "deleted pool #{pool_id} from Katello"
        end
      end
    end
  end
end
