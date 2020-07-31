module Katello
  module Pulp3
    class TaskGroup
      WAITING = 'waiting'.freeze
      SKIPPED = 'skipped'.freeze
      RUNNING = 'running'.freeze
      COMPLETED = 'completed'.freeze
      CANCELLED = 'canceled'.freeze
      FAILED = 'failed'.freeze

      IN_PROGRESS_STATES = [WAITING, RUNNING].freeze

      #needed for serialization in dynflow
      delegate :to_hash, :to => :task_group_data
      delegate :dig, :to => :task_group_data

      attr_accessor :href

      # A call report Looks like:  {"task":"/pulp/api/v3/tasks/5/"}
      #{
      # "pulp_href":"/pulp/api/v3/task-groups/d9841aaa-8a47-4e31-9018-10e4430766bf/",
      #     "description":"Migration Sub-tasks",
      #     "waiting":0,
      #     "skipped":0,
      #     "running":0,
      #     "completed":0,
      #     "canceled":0,
      #     "failed":1
      # }

      def self.new_from_href(smart_proxy, href)
        group = self.new(smart_proxy, {'pulp_href' => href})
        group.clear_task_group_data
        group
      end

      def initialize(smart_proxy, data)
        @smart_proxy = smart_proxy
        @pulp_data = data.with_indifferent_access
        @href = @pulp_data['pulp_href']
        Rails.logger.error("Got empty pulp_href on #{@pulp_data}") if @href.nil?
      end

      def task_group_data
        @pulp_data ||= tasks_groups_api.read(@href).as_json.with_indifferent_access
      end

      def tasks_groups_api
        ::Katello::Pulp3::Api::Core.new(@smart_proxy).task_groups_api
      end

      def done?
        task_group_data['all_tasks_dispatched'] = true && IN_PROGRESS_STATES.all? { |state| task_group_data[state] == 0 }
      end

      def poll
        clear_task_group_data
        task_group_data
      end

      def clear_task_group_data
        @pulp_data = nil
      end

      def started?
        [SKIPPED, RUNNING, COMPLETED, CANCELLED, FAILED].any? { |state| task_group_data[state] }
      end

      def error
        if task_group_data[FAILED] > 0
          "#{task_group_data[FAILED]} subtask(s) failed for task group #{@href}."
        end
      end

      def cancel
      end
    end
  end
end
