module Actions
  module Katello
    module Applicability
      class Scheduler < Actions::Base
        include ::Dynflow::Action::Singleton

        DRAIN_SLEEP_SECONDS = 3

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def run(_event = nil)
          drain_queue
          suspend
        end

        # TODO: consider error scenarios more closely
        def drain_queue
          until (hosts = ::Katello::ApplicableHostQueue.pop_hosts).empty?
            ForemanTasks.async_task(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: hosts.map(&:host_id))
            sleep DRAIN_SLEEP_SECONDS unless hosts.length == ::Katello::ApplicableHostQueue.batch_size # allow some time for the queue to fill
          end
        rescue => e
          Rails.logger.error("Error while draining applicability queue #{e}")
        end
      end
    end
  end
end
