module Katello
  module EventDaemon
    module Services
      class AgentEventReceiver
        class Handler
          def handle(message)
            ::Katello::Util::Support.with_db_connection do
              ::Katello::Agent::ClientMessageHandler.handle(message)
            rescue => e
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
            agent_connection = ::Katello::Agent::Connection.new
            agent_connection.fetch_agent_messages(Handler.new)
          end
        end

        def self.close
          @thread&.kill
        end

        def self.running?
          @thread&.status.present?
        end

        def self.status(refresh: true)
          {
            running: running?
          }
        end
      end
    end
  end
end
