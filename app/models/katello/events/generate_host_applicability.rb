module Katello
  module Events
    class GenerateHostApplicability
      EVENT_TYPE = 'generate_host_applicability'.freeze

      def self.retry_seconds
        180
      end

      def initialize(object_id)
      end

      def run
        return if ::Katello::ApplicableHostQueue.queue_depth == 0

        begin
          while ::Katello::ApplicableHostQueue.queue_depth != 0
            hosts = ::Katello::ApplicableHostQueue.pop_hosts
            ForemanTasks.async_task(::Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: hosts.map(&:host_id))
          end
        rescue => e
          self.retry = true if e.is_a?(ForemanTasks::Lock::LockConflict)
          raise e
        end
      end
    end
  end
end
