#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::V2::DyntasksController < Api::V2::ApiController

  before_filter :authorize

  def rules
    test = lambda do
      # TODO
      return true
    end
    {
      :search => test,
    }
  end

  api :POST, "/dyntasks", "List dynflow tasks for uuids"
  param :conditions, Array, :desc => 'List of uuids to fetch info about' do
    param :type, %w[user resource]
    param :user_id, String, :desc => <<-DESC
      In case :type = 'user', find tasks for the user
    DESC
    param :resource_type, String, :desc => <<-DESC
      In case :type = 'resource', what resource type we're searching the tasks for
    DESC
    param :resource_type, String, :desc => <<-DESC
      In case :type = 'resource', what resource id we're searching the tasks for
    DESC
    param :page, String
    param :per_page, String
  end
  desc <<-DESC
    For every condition it returns the list of tasks that satisfty the condition.
    The reason for supporting multiple conditions is the UI that might be ending
    needing periodic updates on task status for various conditions at the same time.
    This way, it is possible to get all the task statuses with one request.
  DESC
  def search
    conditions = Array(params[:conditions])
    @tasks = {}

    ret = conditions.map do |condition|
      { condition: condition,
        tasks: condition_tasks(condition) }
    end
    render :json => ret
  end

  private

  def condition_tasks(condition)
    DynflowTask.tap do |scope|
      scope = ordering_scope(scope, condition)
      scope = search_scope(scope, condition)
      scope = pagination_scope(scope, condition)
    end.all.map { |task| task_hash(task) }
  end

  def search_scope(scope, condition)
    case condition[:type]
    when 'user'
      if condition[:user_id].blank?
        raise HttpErrors::BadRequest, _("User condition requires user_id to be specified")
      end
      scope.where(user_id: condition[:user_id])
    when 'resource'
      if condition[:resource_type].blank? || condition[:resource_id].blank?
        raise HttpErrors::BadRequest, _("User condition requires resource_type and resource_id to be specified")
      end
      scope.joins(:dynflow_locks).where(dynflows_locks:
                                                { resource_type: condition[:resource_type],
                                                  resource_id:   condition[:resource_id] })
    else
      raise HttpErrors::BadRequest, _("Condition %s not supported") % condition[:type]
    end
  end

  def pagination_scope(scope, condition)
    page     = condition[:page] || 1
    per_page = condition[:per_page] || 10
    scope = scope.limit(per_page).offset((page - 1) * per_page)
  end

  def ordering_scope(scope, condition)
    scope.joins(:dynflow_execution_plan).
        order('dynflow_execution_plans.started_at DESC')
  end

  def task_hash(task)
    return @tasks[task.uuid] if @tasks[task.uuid]
    task_hash = task.as_json
    task_hash[:started_at] = task.execution_plan.started_at
    task_hash[:ended_at] = task.execution_plan.ended_at
    task_hash[:state] = task.execution_plan.state
    task_hash[:result] = task.execution_plan.result
    task_hash[:progress] = task.execution_plan.progress
    @tasks[task.uuid] = task_hash
  end

end
