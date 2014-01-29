module Actions
  module Helpers
    module PulpTask
      include Dynflow::Action::Polling

      def done?
        !!external_task[:finish_time]
      end

      def external_task
        output[:pulp_task]
      end

      private

      def external_task=(external_task_data)
        output[:pulp_task] = external_task_data
      end

      def poll_external_task
        as_pulp_user { task_resource.poll(external_task[:task_id]) }
      end

      def task_resource
        ::Katello.pulp_server.resources.task
      end
    end
  end
end
