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


  TYPES = { :package_install => {:name => _("Package Install")},
            :package_update =>  {:name => _("Package Update")},
            :package_remove => {:name => _("Package Remove")},
            :package_group_install => { :name => _("Package Group Install")},
            :package_group_update => {:name => _("Package Group Update")},
            :package_group_remove => {:name => _("Package Group Remove")},
  }.with_indifferent_access


  def self.refresh(ids)
    ids.each do |id|
      TaskStatus.find(id).refresh_pulp
    end
  end

  def self.refresh_for_system(sid)
    query = SystemTask.select(:task_status_id).joins(:task_status).where(:system_id => sid)
    ids = query.where("task_statuses.state"=>[:waiting, :running]).collect {|row| row[:task_status_id]}
    refresh(ids)
    TaskStatus.where("task_statuses.id in (#{query.to_sql})")
  end

  def self.make system, pulp_task, task_type, parameters
    task_status = PulpTaskStatus.using_pulp_task(pulp_task) do |t|
       t.organization = system.organization
       t.task_type = task_type
       t.parameters = parameters
    end
    task_status.save!

    system_task = SystemTask.create!(:system => system, :task_status => task_status)
    system_task
  end

  def humanize_type
    { :package_install => _("Package Install"),
      :package_update =>  _("Package Update"),
      :package_remove => _("Package Remove"),
      :package_group_install => _("Package Group Install"),
      :package_group_update => _("Package Group Update"),
      :package_group_remove => _("Package Group Remove"),
    }[task_status.task_type.to_sym].to_s
  end

  def humanize_parameters
    humanized_parameters = []
    parameters = task_status.parameters
    if packages = parameters[:packages]
      humanized_parameters.concat(packages)
    end
    if groups = parameters[:groups]
      humanized_parameters.concat(groups.map {|g| "@#{g}"})
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
      if result.empty?
        packages_change_description([], action)
      else
        result.each do |(group, packages)|
          ret << "@#{group}\n"
          ret << packages_change_description(packages, action)
          ret << "\n"
        end
      end
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

  def packages_change_description(packages, action)
    ret = ""
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
      if action == :updated
          ret << packages.map do |(new_version, details)|
            detail = new_version
            unless details[:updates].blank?
              detail += " " + _("updated") + " " + details[:updates].join("\n")
            end
            unless details[:obsoletes].blank?
              detail += " " + _("obsoleted") + " " + details[:obsoletes].join("\n")
            end
            detail
          end.join(" \n")
      else
      verb = case action
             when :removed then _("removed")
             else ("installed")
             end
      ret << packages.map{|i| "#{i} #{verb}"}.join("\n")
      end
    end
    ret
  end

  def error_description
    errors, stacktrace = task_status.result[:errors]
    puts "errors are: #{errors.pretty_inspect}"
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
  end

  def as_json(*args)
    methods = [:description, :result_description]
    ret = self.task_status.as_json(:except => task_status.as_json(:except => :id))
    ret.merge!(super(:only => methods, :methods => methods))
    ret[:system_name] = system.name
    ret
  end


end
