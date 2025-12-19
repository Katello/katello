module Katello
  module Events
    class GenerateHostApplicability
      EVENT_TYPE = 'generate_host_applicability'.freeze

      def initialize(object_id)
      end

      def run
        return if ::Katello::ApplicableHostQueue.queue_depth == 0

        while ::Katello::ApplicableHostQueue.queue_depth != 0
          hosts = ::Katello::ApplicableHostQueue.pop_hosts
          ForemanTasks.async_task(::Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: hosts.map(&:host_id))
        end
      end
    end
  end
end
