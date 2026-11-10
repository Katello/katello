module Actions
  module Katello
    module Applicability
      module Hosts
        # A system execution plan, not a permanently running user task: it must
        # not block maintenance that waits for ForemanTasks::Task to finish.
        class PollQueue < Dynflow::Action
          include Dynflow::Action::Polling
          include Dynflow::Action::Singleton
          include Dynflow::Action::Cancellable

          middleware.use Actions::Middleware::RailsExecutorWrap

          def self.start(world)
            filter = Dynflow::Coordinator::SingletonActionLock.unique_filter(name)
            return if world.coordinator.find_locks(filter).any?

            result = world.trigger(self)
            if result.is_a?(Dynflow::World::PlaningFailed) && world.coordinator.find_locks(filter).empty?
              fail result.error
            end
          end

          def invoke_external_task
            true
          end

          def poll_external_task
            ::User.as_anonymous_admin do
              ::Katello::ApplicableHostQueue.dispatch_batches do |host_ids|
                ::ForemanTasks.async_task(::Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: host_ids)
              end
            end
            true
          rescue StandardError => e
            # The queue retains an unacknowledged batch. A transient database or
            # scheduling error must not permanently stop the shared consumer.
            action_logger.error("Applicability queue dispatch failed: #{e.message}")
            true
          end

          def done?
            false
          end

          def cancel!
            singleton_unlock!
          end

          def poll_intervals
            [3]
          end
        end
      end
    end
  end
end
