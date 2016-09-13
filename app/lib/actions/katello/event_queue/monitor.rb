module Actions
  module Katello
    module EventQueue
      class Monitor < Actions::Base
        Event = Algebrick.type do
          fields! event_type: String, object_id: Integer, created_at: DateTime
        end

        Fatal = Algebrick.type do
          fields! backtrace: String, message: String, kind: String
        end

        Ready = Algebrick.atom
        Close = Algebrick.atom

        cattr_accessor :triggered_action

        def self.ensure_running(world = ForemanTasks.dynflow.world)
          world.coordinator.acquire(RunOnceCoordinatorLock.new(world)) do
            unless ForemanTasks::Task::DynflowTask.for_action(self).running.any?
              self.triggered_action = ForemanTasks.trigger(self)
            end
          end
        rescue Dynflow::Coordinator::LockError
          return false
        end

        def plan
          # Make sure we don't have two concurrent listening services competing
          if already_running?
            fail "Action #{self.class.name} is already active"
          end
          plan_self
        end

        def run(event = nil)
          match(event,
                (on nil do
                  initialize_service
                end),
                (on Ready do
                  listen_for_events
                end),
                (on Event do
                   act_on_event(event)
                 end),
                (on Close | Dynflow::Action::Cancellable::Cancel do
                   close_service
                 end),
                (on Fatal do
                   restart_poller(event)
                 end),
                (on Dynflow::Action::Skip do
                   # do nothing, just skip
                 end))
        rescue => e
          action_logger.error(e.message)
          close_service
          error!(e)
        end

        def restart_poller(_event)
          suspend do |suspended_action|
            SuspendedAction.new(suspended_action).notify_ready
          end
        end

        def close_service
          PollerThread.close
        end

        def initialize_service
          ::Katello::EventQueue.reset_in_progress
          PollerThread.initialize(world.logger)
          suspend do |suspended_action|
            SuspendedAction.new(suspended_action).notify_ready

            unless Rails.env.test?
              world.before_termination do
                finish_service
              end
            end
          end
        end

        def finish_service
          suspended_action.ask(Close).wait
          if self.class.triggered_action
            self.class.triggered_action.finished.wait
          else
            max_attempts = 10
            (1..max_attempts).each do |attempt|
              task.reload
              if !task.pending? || task.paused?
                break
              else
                sleep 1 if attempt != max_attempts
              end
            end
          end
        end

        def listen_for_events
          suspend do |suspended_action|
            PollerThread.instance.poll_for_events(SuspendedAction.new(suspended_action))
          end
        end

        def act_on_event(event)
          ::User.as_anonymous_admin do
            output[:last_event] = "#{event.event_type} - #{event.object_id}"
            ::Katello::EventQueue.event_class(event.event_type).new(event.object_id).run
          end
        rescue => e
          world.logger.error(e.message)
          world.logger.error(e.backtrace.join("\n"))
          output[:last_error] = e.message
        ensure
          ::Katello::EventQueue.clear_events(event.event_type, event.object_id, event.created_at)
          suspend
        end

        def humanized_name
          _('Monitor Event Queue')
        end
      end
    end
  end
end
