module Katello
  class PulpTaskStatus < TaskStatus
    WAIT_TIMES = [0.5, 1, 2, 4, 8, 16].freeze
    WAIT_TIME_STEP = 5

    validates_lengths_from_database

    def refresh
      PulpTaskStatus.refresh(self)
    end

    def after_refresh
      #potentially used by child class, see PulpSyncStatus for example
    end

    def affected_units
      self.result['num_changes']
    end

    def error
      self.result[:errors][0] if self.error? && self.result[:errors]
    end

    def self.dump_state(pulp_status, task_status)
      if !pulp_status.key?(:state) && pulp_status[:result] == "success"
        # Note: if pulp_status doesn't contain a state, the status is coming from pulp sync history
        pulp_status[:state] = Status::FINISHED.to_s
      end

      task_status.attributes = {
        :uuid => pulp_status[:task_id],
        :state => pulp_status[:state] || pulp_status[:result],
        :start_time => pulp_status[:start_time] || pulp_status[:start_time],
        :finish_time => pulp_status[:finish_time],
        :progress => pulp_status,
        :result => pulp_status[:result].nil? ? {:errors => [pulp_status[:exception], pulp_status[:traceback]]} : pulp_status[:result]
      }
      task_status.save! unless task_status.new_record?
      task_status
    end

    def self.refresh(task_status)
      pulp_task = Katello.pulp_server.resources.task.poll(task_status.uuid)

      self.dump_state(pulp_task, task_status)
      task_status.after_refresh
      task_status
    end
  end
end
