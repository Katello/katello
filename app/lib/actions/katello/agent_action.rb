module Actions
  module Katello
    class AgentAction < Actions::EntryAction
      include Actions::Base::Polling
      include Helpers::Presenter

      def dispatch_agent_action
        fail NotImplementedError
      end

      def agent_action_type
        nil
      end

      def run(event = nil)
        unless event == Dynflow::Action::Skip
          super
        end
      end

      def on_finish
        fail_on_errors
      end

      def done?
        dispatch_history&.status&.present?
      end

      def invoke_external_task
        history = dispatch_agent_action
        output[:dispatch_history_id] = history.id
        schedule_timeout(accept_timeout)
      end

      def poll_external_task
        history = dispatch_history
        progress = if history&.status&.present?
                     1
                   elsif history&.accepted_at
                     0.1
                   else
                     0
                   end
        {
          progress: progress
        }
      end

      def accept_timeout
        Setting['content_action_accept_timeout']
      end

      def finish_timeout
        Setting['content_action_finish_timeout']
      end

      def process_timeout
        history = dispatch_history

        if history&.accepted_at.blank?
          fail _("Host did not respond within %s seconds. The task has been cancelled. Is katello-agent installed and goferd running on the Host?") % accept_timeout
        end

        if history&.status.blank?
          fail _("Host did not finish content action in %s seconds.  The task has been cancelled.") % finish_timeout
        end
      end

      def fail_on_errors
        if output[:dispatch_history_id]
          errors = presenter.error_messages

          if errors.any?
            fail errors.join("\n")
          end
        end
      end

      def presenter
        Actions::Katello::Agent::DispatchHistoryPresenter.new(dispatch_history, agent_action_type)
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Skip
      end

      def dispatch_history
        if output[:dispatch_history_id]
          ::Katello::Agent::DispatchHistory.find_by_id(output[:dispatch_history_id])
        end
      end
    end
  end
end
