module Actions
  module Candlepin
    class ImportPoolHandler
      def initialize(logger)
        @logger = logger
      end

      def handle(message)
        @logger.debug("message received from subscriptions queue ")
        @logger.debug("message subject: #{message.subject}")

        ::User.current = ::User.anonymous_admin

        message_handler = ::Katello::Candlepin::MessageHandler.new(message)

        case message_handler.subject
        when /entitlement\.created/
          message_handler.import_pool_by_reference_id
          message_handler.create_pool_on_host
        when /entitlement\.deleted/
          message_handler.import_pool_by_reference_id
          message_handler.remove_pool_from_host
        when /pool\.created/
          message_handler.import_pool_by_entity_id
        when /pool\.deleted/
          message_handler.import_pool_by_entity_id
        when /compliance\.created/
          reindex_consumer(message_handler)
        end
      end

      private

      def reindex_consumer(message_handler)
        subscription_facet = message_handler.subscription_facet
        sub_status = message_handler.sub_status
        uuid = message_handler.consumer_uuid
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
