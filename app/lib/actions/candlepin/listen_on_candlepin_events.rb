#
module Actions
  module Candlepin
    class SuspendedAction
      def initialize(suspended_action)
        @suspended_action = suspended_action
      end

      def notify_message_received(id, subject, content)
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Event[id, subject, content]
      end

      def notify_fatal(error)
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Fatal[error.backtrace && error.backtrace.join('\n'), error.message, error.class.name]
      end

      def notify_connected
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Connected
      end

      def notify_not_connected(message)
        ForemanTasks.dynflow.world.clock.ping(@suspended_action, 5, Actions::Candlepin::ListenOnCandlepinEvents::Reconnect[message])
      end

      def notify_finished
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Close
      end
    end

    class ListenOnCandlepinEvents < Actions::Base
      Connected = Algebrick.atom

      Reconnect = Algebrick.type do
        fields! message: String
      end

      Event = Algebrick.type do
        fields! message_id: String, subject: String, content: String
      end

      Fatal = Algebrick.type do
        fields! backtrace: String, message: String, kind: String
      end

      Close = Algebrick.atom

      class RunOnceCoordinatorLock < Dynflow::Coordinator::LockByWorld
        def initialize(world)
          super
          @data[:id] = 'listen-on-candlepin-events'
        end
      end

      class << self
        attr_reader :triggered_action

        def ensure_running(world = ForemanTasks.dynflow.world)
          world.coordinator.acquire(RunOnceCoordinatorLock.new(world)) do
            unless ForemanTasks::Task::DynflowTask.for_action(self).running.any?
              @triggered_action = ForemanTasks.trigger(self)
            end
          end
        rescue Dynflow::Coordinator::LockError
          return false
        end
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
                # initialize the listening service
                initialize_service
              end),
              (on Reconnect do
                 connect_listening_service(event)
               end),
              (on Connected do
                 poll_listening_service(event)
               end),
              (on Event do
                 # react on the event, probably calling ForemanTasks.async_task
                 act_on_event(event)
               end),
              (on Close | Dynflow::Action::Cancellable::Cancel do
                 # we finished with the listening serivce
                 close_service
               end),
              (on Fatal do
                 close_service_with_error(event)
               end),
              (on Dynflow::Action::Skip do
                 # do nothing, just skip
               end))
      rescue => e
        action_logger.error(e.message)
        close_service
        error!(e)
      end

      def close_service_with_error(event)
        error = Exception.new("#{event.kind}: #{event.message}")
        error.set_backtrace([event.backtrace])
        error!(error)
      ensure
        close_service
      end

      def connect_listening_service(event)
        CandlepinListeningService.instance.close
        output[:error] = event.message

        suspend do |suspended_action|
          CandlepinListeningService.instance.start(SuspendedAction.new(suspended_action))
        end
      end

      def poll_listening_service(_event)
        output[:connection] = "Connected"
        output[:error] = nil
        suspend do |suspended_action|
          CandlepinListeningService.instance.poll_for_messages(SuspendedAction.new(suspended_action))
        end
      end

      def initialize_service
        output[:messages] = 0
        output[:last_message] = nil
        suspend do |suspended_action|
          #send back @event_type by wake up action like
          # suspended_action << @event_type
          begin
            initialize_listening_service(SuspendedAction.new(suspended_action))
          rescue => e
            error!(e)
            raise e
          end
          unless Rails.env.test?
            world.before_termination do
              finish_service
            end
          end
        end
      end

      def finish_service
        log_prefix = "Finishing #{self.class.name} #{task.id}"
        action_logger.info(log_prefix)
        # make sure we close the service at exit to finish the listening action
        suspended_action.ask(Close).wait
        # if the triggered_action is nil, it means the action was resumed from
        # previous run due to some unexpected termination of previous process
        if self.class.triggered_action
          self.class.triggered_action.finished.wait
        else
          max_attempts = 10
          (1..max_attempts).each do |attempt|
            task.reload
            if !task.pending? || task.paused?
              break
            else
              action_logger.info("#{log_prefix}: attempt #{attempt}/#{max_attempts}")
              if attempt == max_attempts
                action_logger.info("#{log_prefix} failed, skipping")
              else
                sleep 1
              end
            end
          end
        end
      end

      def act_on_event(event)
        begin
          output[:connection] = "Connected"
          Actions::Candlepin::ImportPoolHandler.new(Rails.logger).handle(event)
          output[:last_message] = "#{event.message_id} - #{event.subject}"
          output[:last_message_time] = DateTime.now.to_s
          output[:messages] = event.message_id
        rescue => e
          output[:last_event_error] = e.message
          action_logger.error("Failed Candlepin Event: #{e.message}")
          action_logger.error(e.backtrace.join('\n'))
        end
        suspend
      end

      def configured?
        SETTINGS[:katello].key?(:qpid) &&
          SETTINGS[:katello][:qpid].key?(:url) &&
          SETTINGS[:katello][:qpid].key?(:subscriptions_queue_address)
      end

      def initialize_listening_service(suspended_action)
        if configured?
          CandlepinListeningService.initialize(world.logger,
                                             SETTINGS[:katello][:qpid][:url],
                                             SETTINGS[:katello][:qpid][:subscriptions_queue_address])
          suspended_action.notify_not_connected("initialized...have not connected yet")
        else
          action_logger.error("katello has not been configured for qpid.url and qpid.subscriptions_queue_address")
          suspended_action.notify_finished
        end
      rescue => e
        Rails.logger.error(e.message)
        Rails.logger.error(e.backtrace)
        error!(e)
      end

      def error_message(error_id)
        CandlepinListeningService.instance.errors[error_id]
      end

      def close_service
        CandlepinListeningService.close
      end
    end
  end
end
