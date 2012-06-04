#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Job < ActiveRecord::Base
  include Glue
  include Authorization
  include AsyncOrchestration

  belongs_to :job_owner, :polymorphic => true

  has_many :job_tasks, :dependent => :destroy
  has_many :task_statuses, :through => :job_tasks

  class << self
    def refresh_tasks(ids)
      unless ids.nil? || ids.empty?
        uuids = TaskStatus.select(:uuid).where(:id => ids).collect{|t| t.uuid}
        ret = Resources::Pulp::Task.find(uuids)
        ret.each do |pulp_task|
          PulpTaskStatus.dump_state(pulp_task, TaskStatus.find_by_uuid(pulp_task["id"]))
        end
      end
    end

    def refresh_for_owner(owner)
      # retrieve any 'in progress' tasks associated with the owner (e.g. system group)
      tasks = TaskStatus.where('task_statuses.state' => [:waiting, :running]).where(
          'jobs.job_owner_id' => owner.id, 'jobs.job_owner_type' => owner.class.name).joins(
          'INNER JOIN job_tasks ON job_tasks.task_status_id = task_statuses.id').joins(
          'INNER JOIN jobs ON jobs.id = job_tasks.job_id')

      # refresh those tasks to get latest status
      ids = tasks.collect{|row| row[:id]}
      refresh_tasks(ids)

      # retrieve the jobs for the current owner (e.g. system group)
      query = Job.where(:job_owner_id => owner.id, :job_owner_type => owner.class.name)
    end
  end

  def create_tasks owner, pulp_tasks, task_type, parameters
    # create an array of task status objects
    tasks = []
    pulp_tasks.each do |task|
      task_status = PulpTaskStatus.new(
          :organization => owner.organization,
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

  def as_json(options)
    first_task = self.task_statuses.first
    #check for first task
    if first_task.nil?
      return {:id=>self.id}
    else
      #since this is a collection of tasks, where
      # the type and parameters will all be the same
      #  lets not return them in each task object, but instead
      #  put them in the job
      tasks = self.task_statuses.collect{|t|
        {
            :id=>t.id,
            :result=>t.result,
            :progress=>t.progress,
            :state=>t.state,
            :uuid=>t.uuid,
            :start_time=>t.start_time,
            :finish_time=>t.finish_time
        }
      }
      return {
          :id=>self.id,
          :created_at=>first_task.created_at,
          :task_type=>first_task.task_type,
          :parameters=>first_task.parameters,
          :tasks=>tasks
      }
    end
  end

  def status_message
    # for the type of job, look at the first task... for now, the type is always assumed to be
    # the same for all tasks in the job
    first_task = self.task_statuses.first
    details = TaskStatus::TYPES[first_task.task_type]
    message = details[:event_messages][self.state].first
  end

  def state
    # determine the overall status of the job by evaluating the status of it's tasks
    # - running (aka installing), if 1 or more tasks are waiting or running
    # - error, if waiting+running is 0 and at least 1 error has occurred
    # - finished, otherwise...
    running = 0
    error = 0
    self.task_statuses.each do |task|
      if task.state == TaskStatus::Status::WAITING.to_s or task.state == TaskStatus::Status::RUNNING.to_s
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
end
