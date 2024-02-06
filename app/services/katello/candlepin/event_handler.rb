module Katello
  module Candlepin
    class EventHandler
      attr_reader :message_handler

      def initialize(logger)
        @logger = logger
      end

      def handle(message)
        ::User.current = ::User.anonymous_admin

        Katello::Logging.time("candlepin event handled", logger: @logger) do |data|
          data[:subject] = message.subject
          @message_handler = ::Katello::Candlepin::MessageHandler.new(message)
          data[:entity_id] = @message_handler.entity_id
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
            event_no_longer_handled
          when /system_purpose_compliance\.created/
            event_no_longer_handled
          when /owner_content_access_mode\.modified/
            message_handler.handle_content_access_mode_modified
          end
        end
      end

      private

      def event_no_longer_handled
        @logger.error "Received #{message_handler.subject} event from Candlepin. Handling of this event is no longer supported."
      end

      def subscription_facet
        message_handler.subscription_facet
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
