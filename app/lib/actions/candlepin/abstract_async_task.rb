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

      def done?
        ! ::Katello::Resources::Candlepin::Job.not_finished?(external_task)
      end

      private

      def poll_external_task
        ::Katello::Resources::Candlepin::Job.get(external_task[:id])
      end
    end
  end
end
