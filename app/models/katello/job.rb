module Katello
  class Job < Katello::Model
    self.include_root_in_json = false

    include Glue

    belongs_to :job_owner, :polymorphic => true

    has_many :job_tasks, :class_name => "Katello::JobTask", :dependent => :destroy
    has_many :task_statuses, :through => :job_tasks

    validates_lengths_from_database

    class << self
      def refresh_tasks(ids)
        unless ids.nil? || ids.empty?
          uuids = TaskStatus.where(:id => ids).pluck(:uuid)
          uuids.each do |uuid|
            pulp_task = Katello.pulp_server.resources.task.poll(uuid)
            PulpTaskStatus.dump_state(pulp_task, TaskStatus.find_by_uuid(pulp_task[:task_id]))
          end
        end
      end

      def refresh_for_owner(owner)
        # retrieve any 'in progress' tasks associated with the owner (e.g. system group)
        task_status_table = Katello::TaskStatus.table_name
        job_table = Katello::Job.table_name
        job_task_table = Katello::JobTask.table_name

        tasks = TaskStatus.where("#{task_status_table}.state" => [:waiting, :running]).where(
            "#{job_table}.job_owner_id" => owner.id, "#{job_table}.job_owner_type" => owner.class.name).joins(
            "INNER JOIN #{job_task_table} ON #{job_task_table}.task_status_id = #{task_status_table}.id").joins(
            "INNER JOIN #{job_table} ON #{job_table}.id = #{job_task_table}.job_id")

        ids = tasks.select("#{task_status_table}.id").collect { |row| row[:id] }

        # refresh the tasks via pulp
        refresh_tasks(ids) unless ids.empty?

        # retrieve the jobs for the current owner (e.g. system group)
        Job.where(:job_owner_id => owner.id, :job_owner_type => owner.class.name)
      end
    end

    def create_tasks(organization, pulp_tasks, task_type, parameters)
      # create an array of task status objects

      tasks = []
      pulp_tasks.each do |task|
        # if the task was returned with a UUID belonging to a system, associate that system with the task
        unless task[:call_request_tags].blank?
          uuid = task[:call_request_tags].first.split('pulp:consumer:').last
          system = System.where(:uuid => uuid).first
        end

        task_status = PulpTaskStatus.new(
            :organization => organization,
            :task_owner => system,
            :task_type => task_type,
            :parameters => parameters
        )
        task_status.merge_pulp_task!(task)
        task_status.save!
        tasks.push(task_status)
      end

      # add the task statuses to the job
      unless tasks.empty?
        self.task_statuses = tasks
        self.save!
      end

      tasks
    end

    def as_json(_options = {})
      first_task = self.task_statuses.first
      #check for first task
      if first_task.nil?
        return {:id => self.id, :state => 'error', :status_message => 'No tasks in job.'}
      else
        #since this is a collection of tasks, where
        # the type and parameters will all be the same
        #  lets not return them in each task object, but instead
        #  put them in the job
        tasks = self.task_statuses.collect do |t|
          {
            :id => t.id,
            :result => t.result,
            :progress => t.progress,
            :state => t.state,
            :uuid => t.uuid,
            :start_time => t.start_time,
            :finish_time => t.finish_time
          }
        end
        return {
          :id => self.id,
          :pulp_id => self.pulp_id,
          :created_at => first_task.created_at,
          :task_type => first_task.task_type,
          :parameters => first_task.parameters,
          :tasks => tasks,

          :state => self.state,
          :finish_time => self.finish_time,
          :status_message => self.status_message
        }
      end
    end

    def messages
      # Return a hash of the messages that may be rendered to the user to represent the status of the job.
      first_task = self.task_statuses.first
      #check for first task
      if first_task.nil?
        return {:id => self.id}
      else
        return {
          :task_type => TaskStatus::TYPES[first_task.task_type][:english_name],
          :summary_message => summary_message(first_task),
          :requested_action_message => requested_action_message(first_task),
          :pending_action_message => (pending_action_message(first_task) if state == :running),
          :parameters_message => parameters_message(first_task)
        }
      end
    end

    def finish_time
      self.task_statuses.order('finish_time DESC').last.finish_time
    end

    def pending?
      self.state == :running || self.state == :waiting
    end

    def state
      # determine the overall status of the job by evaluating the status of it's tasks
      # - running (aka installing), if 1 or more tasks are waiting or running
      # - error, if waiting+running is 0 and at least 1 error has occurred
      # - finished, otherwise...
      running = 0
      error = 0
      self.task_statuses.each do |task|
        if task.state == TaskStatus::Status::WAITING.to_s || task.state == TaskStatus::Status::RUNNING.to_s
          running += 1
        elsif task.state == TaskStatus::Status::ERROR.to_s
          error += 1
        end
      end

      state = :finished  # assume the job is finished, by default
      if (running > 0)
        state = :running
      elsif (error > 0)
        state = :error
      end
      state
    end

    def status_message
      first_task = self.task_statuses.first
      details = TaskStatus::TYPES[first_task.task_type]
      details[:event_messages][self.state].first
    end

    private

    def pending_action_message(task)
      task.pending_message
    end

    def requested_action_message(task)
      task.message
    end

    def parameters_message(_task)
      first_task = self.task_statuses.first
      first_task.humanize_parameters unless first_task.nil?
    end

    def summary_message(_task)
      summary = ""
      first_task = self.task_statuses.first
      unless first_task.nil?
        job_template = TaskStatus::TYPES[first_task.task_type]
        if job_template[:user_message]
          summary = job_template[:user_message] % first_task.user.login
        else
          summary = job_template[:english_name]
        end
      end
      summary
    end
  end
end
