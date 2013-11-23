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

module Katello
class Api::V2::TasksController < Api::V2::ApiController

  before_filter :find_task, :only => [:show]
  before_filter :authorize

  def rules
    # tasks are used in: synchronization, promotion, packages updating, organizatino deletion
    test = lambda do
      # at the end of organization deletion, there is no organization, so we
      # check if the user has the rights to see the task.
      if @task && User.current == @task.user
        true
      elsif @organization
        Provider.any_readable?(@organization) || @organization.systems_readable?
      else
        false
      end

    end
    # TODO: fix permissions check
    dummy = lambda { true }
    {
      :index  => test,
      :show  => test,
      :bulk_search => dummy,
    }
  end

  api :GET, "/organizations/:organization_id/tasks", "List tasks of given organization"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  def index
    respond :collection => TaskStatus.where(:organization_id => @organization.id)
  end

  api :GET, "/tasks/:id", "Show a task info"
  param :id, :identifier, :desc => "task identifier", :required => true
  def show
    # TODO: remove onces nothing goes though TaskStatus
    @task.refresh if @task.is_a? TaskStatus
    respond_for_show
  end

  api :POST, "/tasks/bulk_search", "List dynflow tasks for uuids"
  param :searches, Array, :desc => 'List of uuids to fetch info about' do
    param :search_id, String, :desc => <<-DESC
      Arbitraty value for client to identify the the request parts with results.
      It's passed in the results to be able to pair the requests and responses properly.
    DESC
    param :type, %w[user resource task]
    param :task_id, String, :desc => <<-DESC
      In case :type = 'task', find the task by the uuid
    DESC
    param :user_id, String, :desc => <<-DESC
      In case :type = 'user', find tasks for the user
    DESC
    param :resource_type, String, :desc => <<-DESC
      In case :type = 'resource', what resource type we're searching the tasks for
    DESC
    param :resource_type, String, :desc => <<-DESC
      In case :type = 'resource', what resource id we're searching the tasks for
    DESC
    param :active_only, :bool
    param :page, String
    param :per_page, String
  end
  desc <<-DESC
    For every search it returns the list of tasks that satisfty the condition.
    The reason for supporting multiple searches is the UI that might be ending
    needing periodic updates on task status for various searches at the same time.
    This way, it is possible to get all the task statuses with one request.
  DESC
  def bulk_search
    searches = Array(params[:searches])
    @tasks = {}

    ret = searches.map do |search_params|
      { search_params: search_params,
        results: search_tasks(search_params) }
    end
    render :json => ret
  end

  private

  def search_tasks(search_params)
    scope = Task.select('DISTINCT tasks.*, dynflow_execution_plans.*')
    scope = ordering_scope(scope, search_params)
    scope = search_scope(scope, search_params)
    scope = active_scope(scope, search_params)
    scope = pagination_scope(scope, search_params)
    scope.all.map { |task| task_hash(task) }
  end

  def search_scope(scope, search_params)
    case search_params[:type]
    when 'all'
      scope
    when 'user'
      if search_params[:user_id].blank?
        raise HttpErrors::BadRequest, _("User search_params requires user_id to be specified")
      end
      scope.joins(:locks).where(locks:
                                { resource_type: 'User',
                                  resource_id:   search_params[:user_id] })
    when 'resource'
      if search_params[:resource_type].blank? || search_params[:resource_id].blank?
        raise HttpErrors::BadRequest, _("Resource search_params requires resource_type and resource_id to be specified")
      end
      scope.joins(:locks).where(locks:
                                { resource_type: search_params[:resource_type],
                                  resource_id:   search_params[:resource_id] })
    when 'task'
      if search_params[:task_id].blank?
        raise HttpErrors::BadRequest, _("Task search_params requires task_id to be specified")
      end
      scope.where(uuid: search_params[:task_id])
    else
      raise HttpErrors::BadRequest, _("Search_Params %s not supported") % search_params[:type]
    end
  end

  def active_scope(scope, search_params)
    if search_params[:active_only]
      scope.active
    else
      scope
    end
  end

  def pagination_scope(scope, search_params)
    page     = search_params[:page] || 1
    per_page = search_params[:per_page] || 10
    scope = scope.limit(per_page).offset((page - 1) * per_page)
  end

  def ordering_scope(scope, search_params)
    scope.joins(:dynflow_execution_plan).
        order('dynflow_execution_plans.started_at DESC')
  end

  def task_hash(task)
    return @tasks[task.uuid] if @tasks[task.uuid]
    task_hash = Rabl.render(task, 'dynflow_task_show', :view_path => 'app/views/api/v2/tasks', :format => :hash)
    @tasks[task.uuid] = task_hash
    return task_hash
  end

  private

  def find_task
    # temporary searching for both Dynflow task and old-style tasks
    @task = Task.find_by_uuid(params[:id])
    # TODO: remove once nothing goes through the old TaskStatus
    @task ||= TaskStatus.find_by_id!(params[:id])
    @organization = @task.organization
  end

end
end
