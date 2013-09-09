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

# rubocop:disable SymbolName
class Api::V2::SystemsController < Api::V1::SystemsController

  include Api::V2::Rendering

  def rules
    hash = super
    hash[:tasks] = lambda{find_system && @system.readable?}
    hash[:task] = lambda{true}
    hash
  end

  def_param_group :system do
    param :facts, Hash, :desc => "Key-value hash of system-specific facts", :action_aware => true
    param :installedProducts, Array, :desc => "List of products installed on the system", :action_aware => true
    param :name, String, :desc => "Name of the system", :required => true, :action_aware => true
    param :type, String, :desc => "Type of the system, it should always be 'system'", :required => true, :action_aware => true
    param :serviceLevel, String, :allow_nil => true, :desc => "A service level for auto-healing process, e.g. SELF-SUPPORT", :action_aware => true
    param :location, String, :desc => "Physical of the system"
    param :content_view_id, :identifier
    param :environment_id, :identifier
  end

  api :PUT, "/consumers/:id", "Update system information (compatibility)"
  api :PUT, "/systems/:id", "Update system information"
  param_group :system
  def update
    super
  end

  api :GET, "/systems/:id", "Show a system"
  param :id, String, :desc => "UUID of the system", :required => true
  def show
    @system_groups = @system.system_groups
    @custom_info = @system.custom_info
    respond
  end

  api :POST, "/systems/:id/system_groups", "Replace existing list of system groups"
  param :system, Hash, :required => true do
    param :system_group_ids, Array, :desc => "List of group ids the system belongs to", :required => true
  end
  def add_system_groups
    ids = params[:system][:system_group_ids] || []
    @system.system_group_ids = ids.uniq
    @system.save!
    respond_for_create
  end

  api :GET, "/systems/:id/packages", "List packages installed on the system"
  param :id, String, :desc => "UUID of the system", :required => true
  def package_profile
    packages = @system.simple_packages.sort { |a, b| a.name.downcase <=> b.name.downcase }
    response = {
      :records  => packages,
      :subtotal => packages.size,
      :total    => packages.size
    }
    respond_for_index :collection => response
  end

  api :GET, "/systems/:id/errata", "List errata available for the system"
  param :id, String, :desc => "UUID of the system", :required => true
  def errata
    errata = @system.errata
    response = {
      :records  => errata.sort_by{ |e| e.issued }.reverse,
      :subtotal => errata.size,
      :total    => errata.size
    }

    respond_for_index :collection => response
  end

  api :GET, "/systems/:id/tasks", "List async tasks for the system"
  def tasks
    query_string = params[:name] ? "name:#{params[:name]}" : params[:search]

    filters = [{:terms => {:task_owner_id => [@system.id]}},
               {:terms => {:task_owner_type => [System.class_name]}}]
    options = {
        :filters       => filters,
        :load_records? => true,
        :default_field => 'message'
    }
    options[:sort_by] = params[:sort_by] if params[:sort_by]
    options[:sort_order] = params[:sort_order] if params[:sort_order]

    if params[:paged]
      options[:page_size] = params[:page_size] || current_user.page_size
    end

    items = Glue::ElasticSearch::Items.new(TaskStatus)
    tasks, total_count = items.retrieve(query_string, params[:offset], options)

    tasks = {
      :records  => tasks,
      :subtotal => total_count,
      :total    => items.total_items
    }

    respond_for_index(:collection => tasks)
  end

  api :GET, "/systems/task/:task_id", "Grab a single system task"
  param :task_id, String, :desc => "Id of the task", :required => true
  def task
    task = TaskStatus.find(params[:task_id]).refresh
    respond_for_show(:resource => task, :template => :task)
  end

end
