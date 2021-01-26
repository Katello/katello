module Katello
  module EventDaemon
    module Services
      class AgentEventReceiver
        STATUS_CACHE_KEY = 'katello_agent_events'.freeze

        class Handler
          attr_accessor :processed, :failed

          def initialize
            @processed = 0
            @failed = 0
          end

          def handle(message)
            ::Katello::Util::Support.with_db_connection do
              ::Katello::Agent::ClientMessageHandler.handle(message)
              @processed += 1
            rescue => e
              @failed += 1
              Rails.logger.error("Error handling Katello Agent client message")
              Rails.logger.error(e.message)
              Rails.logger.error(e.backtrace.join("\n"))
            end
          end
        end

        def self.logger
          ::Foreman::Logging.logger('katello/agent')
        end

        def self.run
          fail("Katello agent event receiver already started") if running?

          @thread = Thread.new do
            @handler = Handler.new
            agent_connection = ::Katello::Agent::Connection.new
            agent_connection.fetch_agent_messages(@handler)
          end
        end

        def self.close
          @thread&.kill
        end

        def self.running?
          @thread&.status.present?
        end

        def self.status(refresh: true)
          Rails.cache.fetch(STATUS_CACHE_KEY, force: refresh) do
            {
              running: running?,
              processed_count: @handler&.processed || 0,
              failed_count: @handler&.failed || 0
            }
          end
        end
      end
    end
  end
end
