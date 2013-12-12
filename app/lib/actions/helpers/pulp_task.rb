module Actions
  module Helpers
    module PulpTask
      include Dynflow::Action::Polling

      private

      def external_task
        output[:pulp_task]
      end

      def external_task=(external_task_data)
        output[:pulp_task] = external_task_data
      end

      def poll_external_task
        as_pulp_user { ::Katello.pulp_server.resources.task.poll(external_task[:task_id]) }
      end

      def done?
        !!external_task[:finish_time]
      end

    end
  end
end
