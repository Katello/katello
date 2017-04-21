module Actions
  module Candlepin
    class MessageWrapper
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
    end

    class ImportPoolHandler
      def initialize(logger)
        @logger = logger
      end

      def handle(message)
        @logger.debug("message received from subscriptions queue ")
        @logger.debug("message subject: #{message.subject}")

        ::User.current = ::User.anonymous_admin

        wrapped_message = MessageWrapper.new(message)
        case message.subject
        when /entitlement\.created/
          import_pool(wrapped_message.content['referenceId'])
        when /entitlement\.deleted/
          import_pool(wrapped_message.content['referenceId'])
        when /pool\.created/
          import_pool(wrapped_message.content['entityId'])
        when /pool\.deleted/
          remove_pool(wrapped_message.content['entityId'])
        when /compliance\.created/
          reindex_consumer(wrapped_message)
        end
      end

      private

      def import_pool(pool_id)
        pool = ::Katello::Pool.find_by(:cp_id => pool_id)
        if pool
          ::Katello::EventQueue.push_event(::Katello::Events::ImportPool::EVENT_TYPE, pool.id)
        else
          ::Katello::Pool.import_pool(pool_id)
        end
      end

      def remove_pool(pool_id)
        pool = ::Katello::Pool.find_by(:cp_id => pool_id)
        if pool
          pool.destroy!
        else
          @logger.debug "Couldn't find pool with candlepin id #{pool_id} in the database"
        end
      end

      def reindex_consumer(message)
        if message.content['newEntity']
          parsed = JSON.parse(message.content['newEntity'])
          uuid = parsed['consumer']['uuid']
          sub_status = parsed['consumer']['entitlementStatus']
          subscription_facet = ::Katello::Host::SubscriptionFacet.find_by_uuid(uuid)

          if subscription_facet && sub_status
            @logger.debug "re-indexing content host #{subscription_facet.host.name}"
            subscription_facet.update_subscription_status(sub_status)
          elsif subscription_facet.nil?
            @logger.debug "skip re-indexing of non-existent content host #{uuid}"
          elsif sub_status.nil?
            @logger.debug "skip re-indexing of empty subscription status #{uuid}"
          end
        end
      end
    end
  end
end
