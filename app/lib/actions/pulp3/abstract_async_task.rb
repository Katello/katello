module Actions
  module Pulp3
    class AbstractAsyncTask < Pulp3::Abstract
      include Actions::Base::Polling
      include ::Dynflow::Action::Cancellable

      WAITING = ['waiting',
                 SKIPPED = 'skipped'.freeze,
                 RUNNING = 'running'.freeze,
                 COMPLETED = 'completed'.freeze,
                 FAILED = 'failed'.freeze,
                 CANCELED = 'canceled'.freeze].freeze

      FINISHED_STATES = [COMPLETED, FAILED, CANCELED, SKIPPED].freeze

      # A call report Looks like:  {"task":"/pulp/api/v3/tasks/5/"}
      # {
      #    "pulp_href":"/pulp/api/v3/tasks/4/",
      #    "pulp_created":"2019-02-21T19:50:40.476767Z",
      #    "job_id":"d0359658-d926-47a2-b430-1b2092b3bd86",
      #    "state":"completed",
      #    "name":"pulp_file.app.tasks.publishing.publish",
      #    "started_at":"2019-02-21T19:50:40.556002Z",
      #    "finished_at":"2019-02-21T19:50:40.618397Z",
      #    "non_fatal_errors":[
      #
      #    ],
      #    "error":null,
      #    "worker":"/pulp/api/v3/workers/1/",
      #    "parent":null,
      #    "spawned_tasks":[
      #
      #    ],
      #    "progress_reports":[
      #
      #    ],
      #    "created_resources":[
      #       "/pulp/api/v3/publications/1/"
      #    ]
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
        when :suspended
          if external_task && external_task.all? { |task| task[:start_time].nil? }
            _("waiting for Pulp to start the task")
          else
            _("waiting for Pulp to finish the task")
          end
        else
          super
        end
      end

      def done?
        external_task&.all? { |task| task[:finish_time] || FINISHED_STATES.include?(task[:state]) }
      end

      def external_task
        output[:pulp_tasks]
      end

      def cancel!
        cancel
        self.external_task = poll_external_task
        # We suspend the action and the polling will take care of finding
        # out if the cancelling was successful
        suspend unless done?
      end

      def cancel
        output[:pulp_tasks].each do |pulp_task|
          data = PulpcoreClient::Task.new(state: 'canceled')
          tasks_api.tasks_cancel(pulp_task['pulp_href'], data)
          if pulp_task['spawned_tasks']
            #the main task may have completed, so cancel spawned tasks too
            pulp_task['spawned_tasks'].each { |spawned| tasks_api.tasks_cancel(spawned['pulp_href'], data) }
          end
        end
      end

      def rescue_external_task(error)
        if error.is_a?(::Katello::Errors::Pulp3Error)
          fail error
        else
          super
        end
      end

      private

      def transform_task_response(response)
        response = [] if response.nil?
        response = [response] unless response.is_a?(Array)
        response = response.map do |task|
          task.as_json
        end
        response
      end

      def external_task=(external_task_data)
        output[:pulp_tasks] = transform_task_response(external_task_data)
        output[:pulp_tasks].each do |pulp_task|
          if (pulp_exception = ::Katello::Errors::Pulp3Error.from_task(pulp_task))
            fail pulp_exception
          end
        end
      end

      def tasks_api
        ::Katello::Pulp3::Api::Core.new(smart_proxy).tasks_api
      end

      def poll_external_task
        external_task.map do |task|
          task = tasks_api.read(task['pulp_href'] || task['task'])
          task.as_json
        end
      end
    end
  end
end
