#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
module Actions
  module Candlepin
    class SuspendedAction
      def initialize(suspended_action)
        @suspended_action = suspended_action
      end

      def notify_message_recieved(id, subject, content)
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Event[id, subject, content]
      end

      def notify_fatal(error)
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Fatal[error.backtrace && error.backtrace.join('\n'), error.message, error.class.name]
      end

      def notify_connected
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Connected
      end

      def notify_not_connected(message)
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::NotConnected[message]
      end

      def notify_finished
        @suspended_action << Actions::Candlepin::ListenOnCandlepinEvents::Close
      end
    end

    class ListenOnCandlepinEvents < Actions::Base
      Connected = Algebrick.atom

      NotConnected = Algebrick.type do
        fields! message: String
      end

      Event = Algebrick.type do
        fields! message_id: String, subject: String, content: String
      end

      Fatal = Algebrick.type do
        fields! backtrace: String, message: String, kind: String
      end

      Close = Algebrick.atom

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
              (on NotConnected do
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
        sleep 5
        output[:connection] = event.message
        suspend do |suspended_action|
          CandlepinListeningService.instance.start(SuspendedAction.new(suspended_action))
        end
      end

      def poll_listening_service(_event)
        output[:connection] = "Connected"
        suspend do |suspended_action|
          CandlepinListeningService.instance.poll_for_messages(SuspendedAction.new(suspended_action))
          at_exit do
            suspended_action << Close
          end
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
          at_exit do
            # make sure we close the service at exit to finish the listening action
            suspended_action << Close
          end
        end
      end

      def act_on_event(event)
        begin
          output[:connection] = "Connected"
          on_event(event)
        rescue => e
          error!(e)
          raise e
        end
        suspend
      end

      def configured?
        ::Katello.config.respond_to?(:qpid) &&
          ::Katello.config.qpid.respond_to?(:url) &&
          ::Katello.config.qpid.respond_to?(:subscriptions_queue_address)
      end

      def initialize_listening_service(suspended_action)
        if configured?
          CandlepinListeningService.initialize(world.logger,
                                             ::Katello.config.qpid.url,
                                             ::Katello.config.qpid.subscriptions_queue_address)
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

      def on_event(event)
        Actions::Candlepin::ReindexPoolSubscriptionHandler.new(Rails.logger).handle(event)
        output[:last_message] = "#{event.message_id} - #{event.subject}"
        output[:messages] = event.message_id
      rescue => e
        close_service
        error!(e)
      end

      def error_message(error_id)
        CandlepinListeningService.instance.errors[error_id]
      end

      def close_service
        output[:connection] = 'disconnected'
        CandlepinListeningService.close
      end
    end
  end
end
