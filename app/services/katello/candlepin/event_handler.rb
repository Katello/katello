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
          when /pool\.created/
            message_handler.import_pool
          when /pool\.deleted/
            message_handler.delete_pool
          end
        end
      end
    end
  end
end
