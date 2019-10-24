module Katello
  module Candlepin
    class EventHandler
      attr_reader :message_handler

      def initialize(logger)
        @logger = logger
      end

      def handle(message)
        @logger.debug("message received from subscriptions queue ")
        @logger.debug("message subject: #{message.subject}")

        ::User.current = ::User.anonymous_admin

        @message_handler = ::Katello::Candlepin::MessageHandler.new(message)

        case message_handler.subject
        when /entitlement\.created/
          message_handler.import_pool
          message_handler.create_pool_on_host
        when /entitlement\.deleted/
          message_handler.import_pool
          message_handler.remove_pool_from_host
        when /pool\.created/
          message_handler.import_pool
        when /pool\.deleted/
          message_handler.delete_pool
        when /^compliance\.created/
          reindex_subscription_status
        when /system_purpose_compliance\.created/
          reindex_purpose_status
        end
      end

      private

      def subscription_facet
        message_handler.subscription_facet
      end

      def reindex_subscription_status
        if message_handler.status.nil?
          @logger.debug "skip re-indexing of empty #{message_handler.subject} status #{message_handler.consumer_uuid}"
          return
        end

        reindex_consumer do
          subscription_facet.update_subscription_status(message_handler.status)
          subscription_facet.update_compliance_reasons(message_handler.reasons)
        end
      end

      def reindex_purpose_status
        reindex_consumer do
          subscription_facet.update_purpose_status(role_status: message_handler.system_purpose.role_status,
                                                   usage_status: message_handler.system_purpose.usage_status,
                                                   addons_status: message_handler.system_purpose.addons_status,
                                                   sla_status: message_handler.system_purpose.sla_status,
                                                   purpose_status: message_handler.system_purpose.overall_status)
        end
      end

      def reindex_consumer
        if subscription_facet.nil?
          @logger.debug "skip re-indexing of non-existent content host #{message_handler.consumer_uuid}"
          return
        end

        @logger.debug "re-indexing content host #{subscription_facet.host.name}"

        yield
      end
    end
  end
end
