module Katello
  module Events
    class GenerateHostApplicability
      EVENT_TYPE = 'generate_host_applicability'.freeze

      def self.retry_seconds
        180
      end

      def initialize(host_id)
        @host = ::Host.find_by_id(host_id)
        Rails.logger.warn "Host not found for ID #{object_id}" if @host.nil?
      end

      def run
        return unless @host

        begin
          ForemanTasks.async_task(::Actions::Katello::Applicability::Host::Generate, host_id: @host.id)
        rescue => e
          self.retry = true if e.is_a?(ForemanTasks::Lock::LockConflict)
          raise e
        end
      end
    end
  end
end
