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

class SystemTask < ActiveRecord::Base
  belongs_to :system
  belongs_to :task_status

  class << self
    def pending_message_for task
      details = TaskStatus::TYPES[task.task_type]
      case details[:type]
        when :package
          p = task.parameters[:packages]
          unless p && p.length > 0
            if "package_update" == task.task_type
              return _("all packages")
            end
            return ""
          end
          if p.length == 1
            return p.first
          else
            return  _("%s (%s other packages)") % [p.first, p.length - 1]
          end
        when :package_group
          p = task.parameters[:groups]
          if p.length == 1
            return p.first
          else
            return  _("%s (%s other package groups)") % [p.first, p.length - 1]
          end
        when :errata
          p = task.parameters[:errata_ids]
          if p.length == 1
            return p.first
          else
            return  _("%s (%s other errata)") % [p.first, p.length - 1]
          end
      end
    end
    def message_for task
      details = TaskStatus::TYPES[task.task_type]
      case details[:type]
        when :package
          p = task.parameters[:packages]
          unless p && p.length > 0
            if "package_update" == task.task_type
              case task.state
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
          msg = details[:event_messages][task.state]
          return n_(msg[1], msg[2], p.length) % [p.first, p.length - 1]
        when :candlepin_event
          return task.result
        when :package_group
          p = task.parameters[:groups]
          msg = details[:event_messages][task.state]
          return n_(msg[1], msg[2], p.length) % [p.first, p.length - 1]
        when :errata
          p = task.parameters[:errata_ids]
          msg = details[:event_messages][task.state]
          return n_(msg[1], msg[2], p.length) % [p.first, p.length - 1]

      end
    end

    def refresh(ids)
      unless ids.nil? || ids.empty?
        uuids = TaskStatus.select(:uuid).where(:id => ids).collect{|t| t.uuid}
        ret = Resources::Pulp::Task.find(uuids)
        ret.each do |pulp_task|
          PulpTaskStatus.dump_state(pulp_task, TaskStatus.find_by_uuid(pulp_task["id"]))
        end
      end
    end

    def refresh_for_system(sid)
      query = SystemTask.select(:task_status_id).joins(:task_status).where(:system_id => sid)

      ids = query.where("task_statuses.state"=>[:waiting, :running]).collect {|row| row[:task_status_id]}
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
        task ||= SystemTask.make(system, event_status, :candlepin_event, :event => event)
      }

      statuses = TaskStatus.where("task_statuses.id in (#{query.to_sql})")
    end

    def make system, pulp_task, task_type, parameters
      task_status = PulpTaskStatus.new(
         :organization => system.organization,
         :task_type => task_type,
         :parameters => parameters,
         :systems => [system]
      )
      task_status.merge_pulp_task!(pulp_task)
      task_status.save!
      task_status.system_tasks.first
    end
  end

  # non self methods
  def humanize_type
    TYPES[task_status.task_type][:name]
  end

  def humanize_parameters
    humanized_parameters = []
    parameters = task_status.parameters
    if packages = parameters[:packages]
      humanized_parameters.concat(packages)
    end
    if groups = parameters[:groups]
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
    case task_status.state.to_s
    when "finished"
      success_description
    when "error"
      error_description
    else ""
    end
  end

  def success_description
    ret = ""
    task_type = task_status.task_type.to_s
    result = task_status.result
    if task_type =~ /^package_group/
      action = task_type.include?("remove") ? :removed : :installed
      ret << packages_change_description(result, action)
    elsif task_status.task_type.to_s == "package_remove"
      ret << packages_change_description(result, :removed)
    else
      if result[:installed]
        ret << packages_change_description(result[:installed], :installed)
      end
      if result[:updated]
        ret << packages_change_description(result[:updated], :updated)
      end
    end
    ret
  end

  def packages_change_description(data, action)
    ret = ""
    packages = (data[:resolved] + data[:deps])
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

  def error_description
    errors, stacktrace = task_status.result[:errors]
    return "" unless errors

    # Handle not very friendly Pulp message
    if errors =~ /^\(.*\)$/
      stacktrace.last.split(":").first
    elsif errors =~ /^\[.*,.*\]$/m
      errors.split(",").map do |error|
        error.gsub(/^\W+|\W+$/,"")
      end.join("\n")
    else
      errors
    end
  rescue
    task_status.result[:errors].join(' ').to_s
  end

  def as_json(*args)
    methods = [:description, :result_description]
    ret = self.task_status.as_json(:except => task_status.as_json(:except => :id))
    ret.merge!(super(:only => methods, :methods => methods))
    ret[:system_name] = system.name
    ret
  end

end
