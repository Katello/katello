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

        def poll_external_task
          until (katello_event = ::Katello::EventQueue.next_event).nil?
            break if world.terminating? # Don't hold up shutdown if the queue is deep

            handler = ::Katello::EventMonitor::PollerThread.new(katello_event, action_logger)

            begin
              handler.run_event
            rescue => e
              output[:last_error] = {
                error_message: e.message,
                error_class: e.class.to_s,
                error_backtrace: e.backtrace[0..5],
                handler: handler.to_hash,
                queue_depth: ::Katello::EventQueue.queue_depth,
              }
            end
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
