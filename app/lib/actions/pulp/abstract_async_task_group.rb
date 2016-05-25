module Actions
  module Pulp
    class AbstractAsyncTaskGroup < Pulp::Abstract
      include Actions::Base::Polling

      # A call report (documented https://github.com/pulp/pulp/blob/master/docs/dev-guide/integration/rest-api/consumer/applicability.rst#id65)
      # Looks like:
      #  {
      #    "_href": "/pulp/api/v2/task_groups/7744e2df-39b9-46f0-bb10-feffa2f7014b/",
      #    "group_id": "7744e2df-39b9-46f0-bb10-feffa2f7014b"
      #  }
      #
      # A TaskGroup (https://github.com/pulp/pulp/blob/master/docs/dev-guide/integration/rest-api/tasks.rst#task-group-management)
      # Looks like:
      # {
      #  "accepted": 0,
      #  "finished": 100,
      #  "running": 4,
      #  "canceled": 0,
      #  "waiting": 2,
      #  "skipped": 0,
      #  "suspended": 0,
      #  "error": 0,
      #  "total": 106
      # }

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
            _("initiating Pulp task")
          else
            _("checking Pulp task status")
          end
        else
          super
        end
      end

      def done?
        finishing_states = ["finished", "canceled", "skipped", "suspended", "error"]
        return false if (finishing_states - external_task.keys).present?
        task_resource.completed?(external_task)
      end

      def external_task
        output["pulp_task_group"]
      end

      private

      def external_task=(external_task_data)
        if external_task_data.key?("group_id")
          output["pulp_task_group"] = {"group_id" => external_task_data["group_id"]}
        else
          output["pulp_task_group"] = {"group_id" => output["pulp_task_group"]["group_id"]}.merge(external_task_data)
        end
      end

      def poll_external_task
        task_resource.summary(output["pulp_task_group"]["group_id"])
      end

      def task_resource
        ::Katello.pulp_server.resources.task_group
      end
    end
  end
end
