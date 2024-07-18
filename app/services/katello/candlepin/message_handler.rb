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
        when 'entitlement.created', 'entitlement.deleted'
          content['referenceId']
        end
      end

      def create_pool_on_host
        return if self.subscription_facet.nil? || pool.nil?
        old_host_ids = subscription_facet_host_ids
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).first_or_create
        pool.import_audit_record(old_host_ids)
      end

      def remove_pool_from_host
        return if self.subscription_facet.nil? || pool.nil?
        old_host_ids = subscription_facet_host_ids
        ::Katello::SubscriptionFacetPool.where(subscription_facet_id: self.subscription_facet.id,
                                               pool_id: pool.id).destroy_all
        pool.import_audit_record(old_host_ids)
      end

      def import_pool(index_hosts = true)
        if pool
          ::Katello::EventQueue.push_event(::Katello::Events::ImportPool::EVENT_TYPE, pool.id)
        else
          begin
            ::Katello::Pool.import_pool(pool_id, index_hosts)
          rescue ActiveRecord::RecordInvalid
            # if we hit this block it's likely that the pool's subscription, product are being created
            # as a result of manifest import/refresh or custom product creation
            Rails.logger.warn("Unable to import pool. It will likely be created by another process.")
          end
        end
      end

      def delete_pool
        if Katello::Pool.where(:cp_id => pool_id).destroy_all.any?
          Rails.logger.info "Deleted Katello::Pool with cp_id=#{pool_id}"
        end
      end

      def handle_content_access_mode_modified
        # Ideally the target_name would be the Candlepin Owner key
        # Since it's the displayName, and we don't update that after org creation, there could be a mismatch
        # For now, find the Candlepin Owner displayName from this event, and tie it back to a Katello org based on owner key
        owners = Katello::Resources::Candlepin::Owner.all
        owner = owners.find { |o| o['displayName'] == target_name }

        unless owner
          fail("Candlepin Owner %s could not be found" % target_name)
        end

        org = ::Organization.find_by!(label: owner['key'])

        Rails.logger.error "Received content_access_mode_modified event for org #{org.label}. This event is no longer supported."
        org.simple_content_access?(cached: false)
      end

      private

      def subscription_facet_host_ids
        ::Katello::SubscriptionFacetPool.where(pool_id: pool_id).joins(:subscription_facet).pluck(:host_id)
      end
    end
  end
end
