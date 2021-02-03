module Actions
  module Katello
    class AgentAction < Actions::EntryAction
      include Dynflow::Action::Timeouts
      include Helpers::Presenter

      def self.agent_message
        fail NotImplementedError
      end

      def agent_action_type
        nil
      end

      def plan(host, options)
        action_subject(host)

        # if already dispatched by bulk action use the provided history ID
        dispatch_history_id = options.dig(:dispatch_histories, host.id.to_s)

        unless dispatch_history_id
          histories = ::Katello::Agent::Dispatcher.dispatch(
            self.class.agent_message,
            [host.id],
            content: options[:content]
          )

          dispatch_history_id = histories.first.id
        end

        plan_self(
          host_id: host.id,
          hostname: host.name,
          content: options[:content],
          dispatch_history_id: dispatch_history_id
        )
      end

      def run(event = nil)
        case event
        when nil
          history = dispatch_history

          if history.finished?
            fail_on_errors
            return
          elsif history.accepted?
            schedule_timeout(finish_timeout)
          else
            schedule_timeout(accept_timeout)
          end

          suspend do |suspended_action|
            history.dynflow_execution_plan_id = suspended_action.execution_plan_id
            history.dynflow_step_id = suspended_action.step_id
            history.save!
          end
        when Dynflow::Action::Timeouts::Timeout
          process_timeout
        when 'accepted'
          schedule_timeout(finish_timeout)
          suspend
        else
          fail_on_errors
        end
      end

      def accept_timeout
        Setting['content_action_accept_timeout']
      end

      def finish_timeout
        Setting['content_action_finish_timeout']
      end

      def process_timeout
        history = dispatch_history

        unless history.accepted?
          fail _("Host did not respond within %s seconds. The task has been cancelled. Is katello-agent installed and goferd running on the Host?") % accept_timeout
        end

        unless history.finished?
          fail _("Host did not finish content action in %s seconds.  The task has been cancelled.") % finish_timeout
        end
      end

      def fail_on_errors
        errors = presenter.error_messages

        if errors.any?
          fail errors.join("\n")
        end
      end

      def presenter
        Actions::Katello::Agent::DispatchHistoryPresenter.new(dispatch_history, agent_action_type)
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Skip
      end

      def dispatch_history
        ::Katello::Agent::DispatchHistory.find_by_id(input[:dispatch_history_id])
      end
    end
  end
end
