module Actions
  module Katello
    module EventQueue
      class Monitor < Actions::Base
        include ::Dynflow::Action::Singleton

        Count = Algebrick.type do
          fields! count: Integer, time: Time
        end

        Fatal = Algebrick.type do
          fields! backtrace: String, message: String, kind: String
        end

        Ready = Algebrick.atom
        Close = Algebrick.atom

        class << self
          attr_reader :triggered_action

          def ensure_running(world = ForemanTasks.dynflow.world)
            unless self.singleton_locked?(world)
              @triggered_action = ForemanTasks.trigger self
            end
          rescue Dynflow::Coordinator::LockError
            return false
          end
        end

        def plan
          # Make sure we don't have two concurrent listening services competing
          plan_self
        end

        def run(event = nil)
          action_logger.debug("message_queue_event: #{event}")
          match(event,
                (on nil do
                  initialize_service
                end),
                (on Ready do
                  listen_for_events
                end),
                (on Count do
                   update_count(event)
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

        def update_count(event)
          output[:count] ||= 0
          output[:count] += event.count
          output[:last_count_update] = event.time
          suspend
        end

        def humanized_name
          _('Monitor Event Queue')
        end
      end
    end
  end
end
