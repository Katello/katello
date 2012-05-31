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

class SystemEventsController < ApplicationController
  before_filter :find_system
  before_filter :authorize

  def section_id
    'systems'
  end


  def rules
    read_system = lambda{@system.readable?}

    {
      :index => read_system,
      :items => read_system,
      :show => read_system,
      :status => read_system,
      :more_events => read_system
    }
  end


  def index
    render :partial=>"events", :layout => "tupane_layout", :locals=>{:system => @system,
                                                                :tasks => tasks}
  end

  def show
    # details
    task = @system.tasks.where("#{TaskStatus.table_name}.id" => params[:id]).first
    task_template = TaskStatus::TYPES[task.task_type]
    type = task_template[:name]
    if task_template[:user_message]
      user_message = task_template[:user_message] % task.user.username
    else
      user_message = task_template[:english_name]
    end
    render :partial=>"details", :layout => "tupane_layout", :locals=>{:type => type, :user_message => user_message,
                                                  :system => @system, :task =>task,
                                                  :system_task => find_system_task(task, @system) }
  end

  def status
    # retrieve the status for the package actions initiated by the client
    statuses = @system.tasks.where(:id => params[:id]).collect do |status|
      status_html = render_to_string(:template => 'system_events/_event_items.html.haml',
                                        :layout => false, :locals => {:include_tr => false, :system => @system, :t => status})
      status.as_json(:status_html => status_html)
    end
    render :json => statuses
  end

  def more_events
    if params.has_key? :offset
      offset = params[:offset].to_i
    else
      offset = current_user.page_size
    end

    statuses = tasks(current_user.page_size + offset)
    statuses = statuses[offset..statuses.length]
    if statuses
      render(:partial => 'more_events', :locals => {:cycle_extra => offset.odd?, :system => @system, :tasks=> statuses})
    else
      render :nothing => true
    end

  end

  def items
    render_proc = lambda do |items, options|
      if items && !items.empty?
        render_to_string(:partial => 'more_events', :locals => {:cycle_extra => false, :system => @system, :tasks=> items})
      else
        "<tr><td>" + _("No events matching your search criteria.") + "</td></tr>"
      end
    end
    search = params[:search]
    render_panel_direct(TaskStatus, {:no_search_history => true,:render_list_proc => render_proc},
                        search, params[:offset], [:finish_time, 'desc'],
                        :filter => {:system_ids => [@system.id]},
                        :load => true,
                        :simple_query => "status:#{search} OR #{search}" )
  end

  protected
  def find_system
    @system = System.find(params[:system_id])
  end

  helper_method :find_system_task
  def find_system_task task, system = nil
    if system
      SystemTask.where(:task_status_id =>  task, :system_id => system).first
    else
      SystemTask.where(:task_status_id =>  task).first
    end
  end


  helper_method :tasks
  def tasks(page_size = current_user.page_size)
    @system.tasks.order("finish_time desc").limit(page_size)
  end

  helper_method :total_events_length
  def total_events_length()
    @system.tasks.length
  end
end
