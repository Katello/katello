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

module Actions
  module Pulp
    class AbstractAsyncTask < Pulp::Abstract
      include Actions::Base::Polling
      include ::Dynflow::Action::Cancellable

      FINISHED_STATES = %w{finished error canceled skipped}

      # A call report (documented http://pulp-dev-guide.readthedocs.org/en/latest/conventions/sync-v-async.html)
      # Looks like:  {
      #     "result": {},
      #     "error": {},
      #     "spawned_tasks": [{"_href": "/pulp/api/v2/tasks/7744e2df-39b9-46f0-bb10-feffa2f7014b/",
      #                    "task_id": "7744e2df-39b9-46f0-bb10-feffa2f7014b" }]
      #     }
      #
      #

      # A Task (documented http://pulp-dev-guide.readthedocs.org/en/latest/integration/rest-api/dispatch/task.html#task-management)
      # Looks like:
      # {
      #  "_href": "/pulp/api/v2/tasks/0fe4fcab-a040-11e1-a71c-00508d977dff/",
      #  "state": "running",
      #  "queue": "reserved_resource_worker-0@your.domain.com",
      #  "task_id": "0fe4fcab-a040-11e1-a71c-00508d977dff",
      #  "task_type": "pulp.server.tasks.repository.sync_with_auto_publish",
      #  "progress_report": {}, # contents depend on the operation
      #  "result": null,
      #  "start_time": "2012-05-17T16:48:00Z",
      #  "finish_time": null,
      #  "exception": null,
      #  "traceback": null,
      #  "tags": [
      #    "pulp:repository:f16",
      #    "pulp:action:sync"
      #  ],
      #  "spawned_tasks": [{"href": "/pulp/api/v2/tasks/7744e2df-39b9-46f0-bb10-feffa2f7014b/",
      #                     "task_id": "7744e2df-39b9-46f0-bb10-feffa2f7014b" }],
      #  "error": null
      #}

      def run(event = nil)
        # do nothing when the action is being skipped
        unless event == Dynflow::Action::Skip
          super
        end
      end

      def done?
        external_task.all?{ |task| !!task[:finish_time] || !!FINISHED_STATES.include?(task[:state]) }
      end

      def external_task
        output[:pulp_tasks]
      end

      def cancel!
        output[:pulp_tasks].each do |pulp_task|
          task_resource.cancel(pulp_task['task_id'])
        end
        self.external_task = poll_external_task
        # We suspend the action and the polling will take care of finding
        # out if the cancelling was successful
        suspend unless done?
      end

      private

      def external_task=(external_task_data)
        external_task_data = [external_task_data] if external_task_data.is_a?(Hash)

        new_tasks = []
        external_task_data.each do |task|
          if task['spawned_tasks'].length > 0
            spawned_ids = task['spawned_tasks'].map{|spawned| spawned['task_id']}
            new_tasks.concat(get_new_tasks(external_task_data, spawned_ids))
          end
        end

        #Combine new tasks and remove call reports
        output[:pulp_tasks] = external_task_data.reject{ |task| task['task_id'].nil?} + new_tasks
        output[:pulp_tasks].each do |pulp_task|
          if pulp_exception = ::Katello::Errors::PulpError.from_task(pulp_task)
            fail pulp_exception
          end
        end
      end

      def get_new_tasks(current_list, spawned_task_ids)
        (spawned_task_ids - current_list.map{ |task| task['task_id'] }).map do |task_id|
          task_resource.poll(task_id)
        end
      end

      def poll_external_task
        external_task.map do |task|
          task_resource.poll(task[:task_id])
        end

      end

      def task_resource
        ::Katello.pulp_server.resources.task
      end
    end
  end
end
