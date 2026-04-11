module Actions
  module Katello
    module Applicability
      class Scheduler < Actions::Base
        include ::Dynflow::Action::Singleton

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def run(_event = nil)
          drain_queue
          suspend
        end

        def drain_queue
          until (hosts = ::Katello::ApplicableHostQueue.pop_hosts).empty?
            ForemanTasks.async_task(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: hosts.map(&:host_id))
            sleep 3 unless hosts.length == ::Katello::ApplicableHostQueue.batch_size # allow some time for the queue to fill
          end
        rescue => e
          Rails.logger.error("Error while draining applicability queue #{e}")
        end
      end
    end
  end
end
