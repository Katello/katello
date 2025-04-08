module Actions
  module Katello
    module EventQueue
      class Monitor < Actions::EntryAction
        include ::Dynflow::Action::Singleton

        Handle = Algebrick.type do
          fields! event_type: String, object_id: Integer
        end

        Poll = Algebrick.atom

        def self.launch(world)
          unless self.singleton_locked?(world)
            ForemanTasks.trigger(self)
          end
        rescue StandardError
          # TODO: what to do here?
          Rails.logger.info("Already started!")
        end

        def plan
          plan_self
        end

        def run(event = nil)
          match(event,
                (on nil do
                  suspend do
                    ::Katello::EventQueue.reset_in_progress
                    plan_event(Poll)
                  end
                end),
                (on Handle do
                  suspend do
                    katello_event = ::Katello::EventQueue.next_event(event.event_type, event.object_id)
                    if katello_event
                      handler = ::Katello::EventMonitor::PollerThread.new
                      handler.run_event(katello_event)
                    end
                    plan_event(Poll)
                  end
                end),
                (on Poll do
                  suspend do
                    katello_event = ::Katello::EventQueue.oldest_runnable_event
                    if katello_event
                      # Passing this data to run avoids extra db querying
                      plan_event(Handle[katello_event.event_type, katello_event.object_id])
                    else
                      plan_event(Poll, 3)
                    end
                  end
                end)
              )
        end
      end
    end
  end
end
