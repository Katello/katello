#
# Copyright 2011-2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class DistributorEventsController < ApplicationController
  before_filter :find_distributor
  before_filter :authorize

  def section_id
    'distributors'
  end

  def rules
    read_distributor = lambda{@distributor.readable?}

    {
      :index => read_distributor,
      :items => read_distributor,
      :show => read_distributor,
      :distributor_status => read_distributor,
      :more_events => read_distributor
    }
  end

  def index
    render :partial=>"events", :locals=>{:distributor => @distributor, :tasks => tasks}
  end

  def show
    # details
    task = @distributor.tasks.where("#{TaskStatus.table_name}.id" => params[:id]).first
    task_template = TaskStatus::TYPES[task.task_type]
    type = task_template[:name]
    if task_template[:user_message]
      user_message = task_template[:user_message] % task.user.username
    else
      user_message = task_template[:english_name]
    end
    render :partial=>"details", :locals=>{:type => type, :user_message => user_message,
                                                                      :distributor => @distributor, :task =>task}
  end

  # retrieve the status for the actions initiated by the client
  def distributor_status
    statuses = {:tasks => []}
    @distributor.tasks.where(:id => params[:task_id]).collect do |status|
      statuses[:tasks] << {
        :id => status.id,
        :pending? => status.pending?,
        :status_html => render_to_string(:template => 'event_items', :layout => false,
                                         :locals => {:include_tr => false, :distributor => @distributor, :t => status})
      }
    end
    render :json => statuses
  end

  def more_events
    offset = params[:offset].try(:to_i) || current_user.page_size

    statuses = tasks(current_user.page_size + offset)
    statuses = statuses[offset..statuses.length]
    if statuses
      render(:partial => 'more_events', :locals => {:cycle_extra => offset.odd?, :distributor => @distributor, :tasks=> statuses})
    else
      render :nothing => true
    end
  end

  def items
    render_proc = lambda do |items, options|
      if items && !items.empty?
        render_to_string(:partial => 'more_events', :locals => {:cycle_extra => false, :distributor => @distributor, :tasks=> items})
      else
        "<tr><td>" + _("No events matching your search criteria.") + "</td></tr>"
      end
    end
    search = params[:search]
    render_panel_direct(TaskStatus, {:no_search_history => true, :render_list_proc => render_proc},
                        search, params[:offset], [:finish_time, 'desc'],
                        :filter => {:task_owner_id => [@distributor.id], :task_owner_type => Distributor.class.name},
                        :load => true,
                        :simple_query => "status:#{search} OR #{search}")
  end

  protected

  def find_distributor
    @distributor = Distributor.find(params[:distributor_id])
  end

  helper_method :tasks
  def tasks(page_size = current_user.page_size)
    @distributor.tasks.order("finish_time desc").limit(page_size)
  end

  helper_method :total_events_length
  def total_events_length
    @distributor.tasks.length
  end
end
