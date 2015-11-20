module Katello
  class PulpTaskStatus < TaskStatus
    WAIT_TIMES = [0.5, 1, 2, 4, 8, 16]
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

    def self.wait_for_tasks(async_tasks)
      async_tasks = async_tasks.collect do |t|
        unless t.nil?
          PulpTaskStatus.using_pulp_task(t)
        end
      end

      timeout_count = 0
      attempts = 0
      loop do
        begin
          break unless any_task_running(async_tasks)
          timeout_count = 0
          attempts += 1
        rescue RestClient::RequestTimeout => e
          timeout_count += 1
          Rails.logger.error "Timeout in pulp occurred: #{timeout_count}"
          raise e if timeout_count >= 10 #10 timeouts in a row, lets bail
          sleep 50 #if we got a timeout, lets backoff and let it catchup
        end
        sleep poll_wait_time(attempts)
      end
      async_tasks
    end

    def self.using_pulp_task(pulp_status)
      if pulp_status.is_a? TaskStatus
        pulp_status
      else
        task_id = pulp_status[:task_id] || pulp_status[:spawned_tasks].first[:task_id]
        pulp_status = Katello.pulp_server.resources.task.poll(task_id)

        task_status = TaskStatus.find_by_uuid(task_id)
        task_status = self.new { |t| yield t if block_given? } if task_status.nil?
        PulpTaskStatus.dump_state(pulp_status, task_status)
      end
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

    def self.any_task_running(async_tasks)
      async_tasks.each do |t|
        t.refresh
        sleep 0.5 # do not overload backend engines
        if !t.finished?
          return true
        elsif t.error?
          fail t.as_json
        end
      end
      return false
    end

    def self.poll_wait_time(attempts)
      if attempts >= WAIT_TIMES.length * WAIT_TIME_STEP
        WAIT_TIMES.last
      else
        WAIT_TIMES[(attempts.to_i / WAIT_TIME_STEP)]
      end
    end
  end
end
