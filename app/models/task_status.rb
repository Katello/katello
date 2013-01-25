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
  include Ext::IndexedModel
  include Ext::Authorization

  belongs_to :organization
  belongs_to :user

  belongs_to :task_owner, :polymorphic => true
  # adding belongs_to :system allows us to perform joins with the owning system, if there is one
  belongs_to :system, :foreign_key => :task_owner_id, :class_name => "System"

  # a task may be optionally associated with a job, but it is not required
  # an example scenario would be a job that is created by performing an action on a system group
  has_one :job_task, :dependent => :destroy
  has_one :job, :through => :job_task

  before_save :setup_task_type

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

  after_destroy :destroy_job

  index_options :json=>{:only=> [:parameters, :result, :organization_id, :start_time, :finish_time, :task_owner_id, :task_owner_type ]},
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
      if (System.class.name == task_owner_type)
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

  def pending?
    self.state.to_s == "waiting" || self.state.to_s == "running"
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

  def as_json(options = {})
    json = super :methods => :pending?
    json.merge(options) if options

    if ('System' == task_owner_type)
      methods = [:description, :result_description]
      json.merge!(super(:only=>methods, :methods => methods))
      json[:system_name] = task_owner.name
    end

    json
  end

  # used by search  to filter tasks by systems :)
  def system_filter_clause
    system_id = task_owner_id if (task_owner_type == 'System')
    {:system_id => system_id}
  end

  def pending_message
    # Retrieve a text message that may be rendered for a 'pending' task's status.  This is used in various places,
    # such as System Event history.
    details = TaskStatus::TYPES[self.task_type]
    case details[:type]
      when :package
        p = self.parameters[:packages]
        unless p && p.length > 0
          if "package_update" == self.task_type
            return _("all packages")
          end
          return ""
        end
        if p.length == 1
          return p.first
        else
          return  _("%{package} (%{rest} other packages)") % {:package => p.first, :rest => p.length - 1}
        end
      when :package_group
        p = self.parameters[:groups]
        if p.length == 1
          return p.first
        else
          return  _("%{group} (%{rest} other package groups)") % {:group => p.first, :rest => p.length - 1}
        end
      when :errata
        p = self.parameters[:errata_ids]
        if p.length == 1
          return p.first
        else
          return  _("%{errata} (%{rest} other errata)") % {:errata => p.first, :rest => p.length - 1}
        end
    end
  end

  def message
    # Retrieve a text message that may be rendered for a task's status.  This is used in various places,
    # such as System Event history.
    details = TaskStatus::TYPES[self.task_type]
    case details[:type]
      when :package
        p = self.parameters[:packages]
        unless p && p.length > 0
          if "package_update" == self.task_type
            case self.state
              when "running"
                return "updating"
              when "waiting"
                return "updating"
              when "error"
                return _("all packages update failed")
              else
                return _("all packages update")
            end
          end
          return ""
        end
        msg = details[:event_messages][self.state]
        return n_(msg[1], msg[2], p.length) % [p.first, p.length - 1]
      when :candlepin_event
        return self.result
      when :package_group
        p = self.parameters[:groups]
        msg = details[:event_messages][self.state]
        return n_(msg[1], msg[2], p.length) % [p.first, p.length - 1]
      when :errata
        p = self.parameters[:errata_ids]
        msg = details[:event_messages][self.state]
        return n_(msg[1], msg[2], p.length) % [p.first, p.length - 1]
    end
  end

  def humanize_type
    TaskStatus::TYPES[self.task_type][:name]
  end

  def humanize_parameters
    humanized_parameters = []
    if packages = self.parameters[:packages]
      humanized_parameters.concat(packages)
    end
    if groups = self.parameters[:groups]
      humanized_parameters.concat(groups.map {|g| g =~ /^@/ ? g : "@#{g}"})
    end
    humanized_parameters.join(", ")
  end

  def description
    ret = ""
    ret << humanize_type << ": "
    ret << humanize_parameters
  end

  def result_description
    case self.state.to_s
    when "finished"
      success_description
    when "error"
      error_description
    else ""
    end
  end

  def success_description
    ret = ""
    task_type = self.task_type.to_s

    # if pulp returns an array response, that indicates that nothing
    # was actually changed on the consumer, so set the result to {}
    result = self.result.is_a?(Array) ? {} : self.result

    if task_type =~ /^package_group/
      action = task_type.include?("remove") ? :removed : :installed
      ret << packages_change_description(result, action)
    elsif self.task_type.to_s == "package_remove"
      ret << packages_change_description(result, :removed)
    else
      if task_type.include?("install")
        ret << packages_change_description(result[:installed], :installed)
      end
      if task_type.include?("update")
        ret << packages_change_description(result[:updated], :updated)
      end
    end
    ret
  end

  def error_description
    errors, stacktrace = self.result[:errors]
    return "" unless errors

    # Handle not very friendly Pulp message
    if errors =~ /^\(.*\)$/
      if stacktrace.class == Array
        stacktrace.last.split(":").first
      else
        stacktrace.split("(").first
      end
    elsif errors =~ /^\[.*,.*\]$/m
      errors.split(",").map do |error|
        error.gsub(/^\W+|\W+$/,"")
      end.join("\n")
    else
      errors
    end
  rescue
    self.result[:errors].join(' ').to_s
  end

  def self.refresh_for_system(sid)
    query = TaskStatus.select(:id).where(:task_owner_type => 'System').where(:task_owner_id => sid)
    ids = query.where(:state => [:waiting, :running]).collect {|row| row[:id]}
    refresh(ids)
    statuses = TaskStatus.where("task_statuses.id in (#{query.to_sql})")

    # Since Candlepin events are not recorded as tasks, fetch them for this system and add them
    # here. The alternative to this lazy loading of Candlepin tasks would be to have each API
    # call that Katello passes through to Candlepin record the task explicitly.
    system = System.find(sid)
    system.events.each {|event|
      event_status = {:id => event[:id], :state => event[:type],
                     :start_time => event[:timestamp], :finish_time => event[:timestamp],
                     :progress => "100", :result => event[:messageText]}
      # Find or create task
      task = statuses.where("#{TaskStatus.table_name}.uuid" => event_status[:id]).first
      task ||= TaskStatus.make(system, event_status, :candlepin_event, :event => event)
    }

    statuses = TaskStatus.where("task_statuses.id in (#{query.to_sql})")
  end

  def self.refresh(ids)
    unless ids.nil? || ids.empty?
      uuids = TaskStatus.select(:uuid).where(:id => ids).collect{|t| t.uuid}
      ret = Resources::Pulp::Task.find(uuids)
      ret.each do |pulp_task|
        PulpTaskStatus.dump_state(pulp_task, TaskStatus.find_by_uuid(pulp_task["id"]))
      end
    end
  end

  def self.make system, pulp_task, task_type, parameters
    task_status = PulpTaskStatus.new(
       :organization => system.organization,
       :task_owner => system,
       :task_type => task_type,
       :parameters => parameters,
       :systems => [system]
    )
    task_status.merge_pulp_task!(pulp_task)
    task_status.save!
    task_status
  end

  protected
  def setup_task_type
    unless self.task_type
      self.task_type = self.class().name
    end
  end

  # If the task is associated with a job and this is the last task associated with
  # the job, destroy the job.
  def destroy_job
    # is this task associated with a job?
    job_id = self.job_task.job_id unless self.job_task.nil?
    if job_id
      job = Job.find(job_id)
      # is this the last task associated with the job?
      if job and job.task_statuses.length == 0
        job.destroy
      end
    end
  end

  def packages_change_description(data, action)
    ret = ""
    packages = data.nil? ? [] : (data[:resolved] + data[:deps])
    if packages.empty?
      case action
      when :updated
        ret << _("No packages updated")
      when :removed
        ret << _("No packages removed")
      else
        ret << _("No new packages installed")
      end
    else
      ret << packages.map do |package_attrs|
        package_attrs[:qname]
      end.join("\n")
    end
    ret
  end

end
