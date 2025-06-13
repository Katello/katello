module Actions
  module Katello
    module EventQueue
      class Monitor < Actions::EntryAction
        include ::Dynflow::Action::Singleton
        include ::Dynflow::Action::Polling

        def self.launch(world)
          unless self.singleton_locked?(world)
            ForemanTasks.trigger(self)
          end
        end

        def invoke_external_task
          ::Katello::EventQueue.initialize
          action_logger.info "Katello Event Queue initialized"
        end

        def run(event = nil)
          case event
          when Skip
            # noop
          else
            super
          end
        end

        def stop_condition
          -> { world.terminating? }
        end

        def poll_external_task
          poller = ::Katello::EventMonitor::PollerThread.new
          User.as_anonymous_admin do
            poller.drain_queue(-> { world.terminating? })
          end
        end

        def done?
          false
        end

        def poll_intervals
          [2]
        end

        def rescue_strategy
          ::Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Katello Event Queue")
        end
      end
    end
  end
end
