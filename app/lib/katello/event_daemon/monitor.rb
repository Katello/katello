module Katello
  module EventDaemon
    class Monitor
      def initialize(services)
        @services = services
        @service_statuses = {}
        @services.keys.each do |service_name|
          @service_statuses[service_name] = { running: 'starting' }
        end
        write_statuses_to_cache
      end

      def start
        ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
          loop do
            check_services
            sleep 5
          end
        end
      end

      def write_statuses_to_cache
        Rails.cache.write(
          Katello::EventDaemon::Runner::STATUS_CACHE_KEY,
          @service_statuses
        )
      end

      def check_services
        @services.each do |service_name, service_class|
          @service_statuses[service_name] = service_class.status
        rescue => error
          Rails.logger.error("Error occurred while pinging #{service_class}")
          Rails.logger.error(error.message)
          Rails.logger.error(error.backtrace.join("\n"))
        ensure
          if error || !@service_statuses.dig(service_name, :running)
            begin
              service_class.close
              service_class.run
              sleep 0.1
              @service_statuses[service_name] = service_class.status
            rescue => error
              Rails.logger.error("Error occurred while starting #{service_class}")
              Rails.logger.error(error.message)
              Rails.logger.error(error.backtrace.join("\n"))
            end
          end
        end
        write_statuses_to_cache
      end
    end
  end
end
