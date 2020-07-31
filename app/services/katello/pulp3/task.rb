module Katello
  module Pulp3
    class Task
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

      WAITING = 'waiting'.freeze
      SKIPPED = 'skipped'.freeze
      RUNNING = 'running'.freeze
      COMPLETED = 'completed'.freeze
      FAILED = 'failed'.freeze
      CANCELED = 'canceled'.freeze

      FINISHED_STATES = [COMPLETED, FAILED, CANCELED, SKIPPED].freeze

      #needed for serialization in dynflow

      delegate :[], :key?, :dig, :to_hash, :to => :task_data

      def initialize(smart_proxy, data)
        @smart_proxy = smart_proxy
        if (href = data['task'])
          @href = href
        else
          @pulp_data = data.with_indifferent_access
          @href = @pulp_data['pulp_href']
          Rails.logger.error("Got empty pulp_href on #{@pulp_data}") if @href.nil?
        end
      end

      def task_data(force_refresh = false)
        @pulp_data = nil if force_refresh
        @pulp_data ||= tasks_api.read(@href).as_json.with_indifferent_access
      end

      def tasks_api
        ::Katello::Pulp3::Api::Core.new(@smart_proxy).tasks_api
      end

      def task_group_href
        task_data[:task_group]
      end

      def done?
        task_data[:finish_time] || FINISHED_STATES.include?(task_data[:state])
      end

      def poll
        task_data(true)
        self
      end

      def started?
        task_data[:start_time]
      end

      def error
        if task_data[:state] == CANCELED
          self.new(_("Task canceled"))
        elsif task_data[:state] == FAILED
          if task_data[:error][:description].blank?
            _("Pulp task error")
          else
            task_data[:error][:description]
          end
        end
      end

      def cancel
        data = PulpcoreClient::Task.new(state: 'canceled')
        tasks_api.tasks_cancel(pulp_task['pulp_href'], data)
        #the main task may have completed, so cancel spawned tasks too
        task_data['spawned_tasks']&.each { |spawned| tasks_api.tasks_cancel(spawned['pulp_href'], data) }
      end
    end
  end
end
