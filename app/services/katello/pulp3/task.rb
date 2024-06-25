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

      attr_reader :pulp_data
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

      def self.version_href(tasks)
        tasks = [tasks] unless tasks.is_a?(Array)
        version_hrefs = tasks.map { |task| task[:created_resources] }.flatten
        version_hrefs = version_hrefs.select { |href| ::Katello::Pulp3::Repository.version_href?(href) }
        Rails.logger.error("Got multiple version_hrefs for pulp task: #{tasks}") if version_hrefs.length > 2
        version_hrefs.last
      end

      def self.publication_href(tasks)
        tasks = [tasks] unless tasks.is_a?(Array)
        publication_hrefs = tasks.map { |task| task[:created_resources] }.flatten
        publication_hrefs = publication_hrefs.select { |href| ::Katello::Pulp3::Repository.publication_href?(href) }
        Rails.logger.error("Got multiple publication hrefs for pulp task: #{tasks}") if publication_hrefs.length > 2
        publication_hrefs.last #return the last href to workaround https://pulp.plan.io/issues/9098
      end

      def task_data(force_refresh = false)
        @pulp_data = nil if force_refresh
        @pulp_data ||= tasks_api.read(@href).as_json.with_indifferent_access
      end

      delegate :tasks_api, to: :core_api

      def core_api
        ::Katello::Pulp3::Api::Core.new(@smart_proxy)
      end

      def task_group_href
        task_data[:task_group] || task_data[:created_resources].find { |href| href.starts_with?("/pulp/api/v3/task-groups/") }
      end

      def done?
        task_data[:finished_at] || FINISHED_STATES.include?(task_data[:state])
      end

      def progress_reports
        task_data['progress_reports']
      end

      def correlation_id
        task_data['logging_cid']
      end

      def poll
        task_data(true)
        self
      end

      def started?
        task_data[:started_at]
      end

      def error
        case task_data[:state]
        when CANCELED
          _("Task canceled")
        when FAILED
          if task_data[:error][:description].blank?
            _("Pulp task error")
          else
            task_data[:error][:description]
          end
        end
      end

      def cancel
        core_api.cancel_task(task_data['pulp_href'])
        #the main task may have completed, so cancel spawned tasks too
        task_data['spawned_tasks']&.each do |spawned|
          core_api.cancel_task(spawned['pulp_href'])
        end
      end
    end
  end
end
