module Actions
  module Candlepin
    class AbstractAsyncTask < Candlepin::Abstract
      include Actions::Base::Polling

      def run(event = nil)
        # do nothing when the action is being skipped
        unless event == Dynflow::Action::Skip
          super
        end
      end

      def humanized_state
        case state
        when :running
          if self.external_task.nil?
            _("initiating %s task") % candlepin
          else
            _("checking %s task status") % candlepin
          end
        when :suspended
          _("waiting for %s to finish the task") % candlepin
        else
          super
        end
      end

      def done?
        check_for_errors!(external_task)
        !::Katello::Resources::Candlepin::Job.not_finished?(external_task)
      end

      def candlepin
        _("Candlepin")
      end

      private

      def job_poll_params
        {}
      end

      def poll_external_task
        ::Katello::Resources::Candlepin::Job.get(external_task[:id], job_poll_params)
      end

      def check_for_errors!(task)
        if task[:state] == 'FAILED'
          fail ::Katello::Errors::CandlepinError, task[:resultData]
        end
      end
    end
  end
end
