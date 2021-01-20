module Katello
  module EventDaemon
    module Services
      class AgentEventReceiver
        include Katello::Agent::Connection

        STATUS_CACHE_KEY = 'katello_agent_status'.freeze

        @failed_count = 0
        @processed_count = 0

        def self.logger
          ::Foreman::Logging.logger('katello/candlepin_events')
        end

        def self.run
          fail("Katello agent event receiver already started") if running?

          @thread = Thread.new do
            fetch_agent_messages(sleep_seconds: 2) do |received|
              handle_message(received)
            end
          end
        end

        def self.handle_message(message)
          ::Katello::Util::Support.with_db_connection(logger) do
            ::Katello::Agent::ClientMessageHandler.handle(message)
          end
          @processed_count += 1
        rescue => e
          @failed_count += 1
          logger.error("Error handling Katello Agent client message")
          logger.error(e.message)
          logger.error(e.backtrace.join("\n"))
        end

        def self.close
          @thread&.kill
          close_connection
          reset
        end

        def self.running?
          agent_connection_open? && @thread&.status.present?
        end

        def self.status(refresh: true)
          Rails.cache.fetch(STATUS_CACHE_KEY, force: refresh) do
            {
              processed_count: @processed_count,
              failed_count: @failed_count,
              running: running?
            }
          end
        end

        def self.reset
          @processed_count = 0
          @failed_count = 0
          @running = false
          Rails.cache.delete(STATUS_CACHE_KEY)
        end
      end
    end
  end
end
