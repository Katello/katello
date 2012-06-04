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

class TaskStatus < ActiveRecord::Base

  require 'util/task_status'
  include Katello::TaskStatusUtil

  serialize :result
  serialize :progress
  serialize :parameters, Hash
  class Status
    WAITING = :waiting
    RUNNING = :running
    ERROR = :error
    FINISHED = :finished
    CANCELED = :canceled
    TIMED_OUT = :timed_out
  end
  include IndexedModel
  include Authorization
  belongs_to :organization
  belongs_to :user
  before_save :setup_task_type

  has_many :system_tasks
  has_many :systems, :through => :system_tasks 

  before_save do |status|
    unless status.user
      status.user = User.current
    end
  end

  # log error to the rails log
  before_save do |status|
    if status.state_changed?
      begin
        if status.state == TaskStatus::Status::ERROR.to_s
          Rails.logger.error "Task #{status.task_type} (#{status.id}) is in error state"
          Rails.logger.debug "Task parameters: #{status.parameters.inspect.to_s[0,255]}, result: #{status.result.inspect.to_s[0,255]}"
        else
          Rails.logger.debug "Task #{status.task_type} (#{status.id}) #{status.state}" if status.id
        end
      rescue => e
          Rails.logger.debug "Unable to report status change" # minor error
      end
    end
  end

  index_options :json=>{:only=> [:parameters, :result,
                     :organization_id, :system_ids, :start_time, :finish_time ]},
                :extended_json=>:extended_index_attrs

  mapping do
   indexes :start_time, :type=>'date'
   indexes :finish_time, :type=>'date'
   indexes :status, :type=>'string', :analyzer => 'snowball'
  end

  def extended_index_attrs
    ret = {}
    ret[:username] = user.username if user

    ret[:status] = state.to_s
    ret[:status] += " pending" if pending?
    if state.to_s == "error" || state.to_s == "timed_out"
      ret[:status] += " fail failure"
    end

    case state.to_s
      when "finished"
        ret[:status] += " completed"
      when "timed_out"
        ret[:status] += " timed out"
    end

    if task_type
      tt = task_type
      unless system_tasks.nil? ||  system_tasks.empty?
        tt = TaskStatus::TYPES[task_type][:english_name]
      end
      ret[:status] +=" #{tt}"
    end
    ret
  end


  def initialize(attrs = nil)
    unless attrs.nil?
      # only keep keys for which we have db columns
      attrs = attrs.reject do |k, v|
        !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
      end
    end

    super(attrs)
  end


  def finished?
    ((self.state != TaskStatus::Status::WAITING.to_s) && (self.state != TaskStatus::Status::RUNNING.to_s)) 
  end

  def error?
    (self.state == TaskStatus::Status::ERROR.to_s)
  end


  def refresh
    self
  end

  def merge_pulp_task!(pulp_task)
    PulpTaskStatus.dump_state(pulp_task, self)
  end

  def refresh_pulp
    PulpTaskStatus.refresh(self)
  end

  def pending?
    self.state.to_s == "waiting" || self.state.to_s == "running"
  end

  def as_json(options = {})
    json = super :methods => :pending?
    json.merge(options) if options
  end

  # used by search  to filter tasks by systems :)
  def system_filter_clause
    {:system_ids => system_ids}
  end

  protected
  def setup_task_type
    unless self.task_type
      self.task_type = self.class().name
    end
  end

end
