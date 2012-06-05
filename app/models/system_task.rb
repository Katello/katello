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
    TaskStatus::TYPES[task_status.task_type][:name]
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
