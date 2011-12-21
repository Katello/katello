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
  skip_before_filter :authorize
  before_filter :find_system
  before_filter :authorize

  def section_id
    'systems'
  end


  def rules
    read_system = lambda{@system.readable?}

    {
      :index => read_system,
      :show => read_system,
      :status => read_system
    }
  end


  def index
    # list of events
    tasks = @system.tasks.order("updated_at desc").limit(50)
    render :partial=>"events", :layout => "tupane_layout", :locals=>{:system => @system, :tasks => tasks}
  end

  def show
    # details
    task = @system.tasks.where("#{TaskStatus.table_name}.id" => params[:id]).first
    task_template = SystemTask::TYPES[task.task_type]
    type = task_template[:name]
    user_message = task_template[:user_message] % task.user.username
    render :partial=>"details", :layout => "tupane_layout", :locals=>{:type => type, :user_message => user_message,
                                                                          :system => @system, :task =>task}
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


  protected
  def find_system
    @system = System.find(params[:system_id])
  end

end
