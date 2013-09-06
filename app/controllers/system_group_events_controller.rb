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

class SystemGroupEventsController < ApplicationController
  before_filter :find_group
  before_filter :authorize

  helper SystemGroupEventsHelper

  def section_id
    'systems'
  end

  def rules
    read_group = lambda{@group.readable?}

    {
      :index => read_group,
      :items => read_group,
      :show => read_group,
      :event_status => read_group,
      :more_items => read_group
    }
  end

  def index
    render :partial=>'system_groups/events/index', :locals=>{:group => @group, :jobs => jobs}
  end

  def show
    job = @group.jobs.where("#{Job.table_name}.id" => params[:id]).first
    if job.nil?
      render :nothing => true
    else
      render :partial=>'system_groups/events/show',
             :locals=>{:group => @group, :job =>job}
    end
  end

  def event_status
    # retrieve the status for the actions initiated by the client
    statuses = {:jobs => [], :tasks => []}

    @group.refreshed_jobs.where(:id => params[:job_id]).collect do |status|
      statuses[:jobs] << {
        :id => status.id,
        :pending? => status.pending?,
        :status_html => render_to_string(:template => 'system_groups/events/_items', :layout => false,
                                         :locals => {:include_tr => false, :group => @group, :job => status})
      }
    end

    TaskStatus.where(:id => params[:task_id]).collect do |status|
      statuses[:tasks] << {
        :id => status.id,
        :pending? => status.pending?,
        :status_html => render_to_string(:template => 'system_groups/events/_system_items', :layout => false,
                                         :locals => {:include_tr => false, :t => status})
      }
    end

    render :json => statuses
  end

  def more_items
    if params.has_key?(:offset)
      offset = params[:offset].to_i
    else
      offset = current_user.page_size
    end

    statuses = jobs(current_user.page_size + offset)
    statuses = statuses[offset..statuses.length]
    if statuses
      render(:partial => 'system_groups/events/more_items', :locals => {:cycle_extra => offset.odd?, :group => @group, :jobs => statuses})
    else
      render :nothing => true
    end
  end

  def items
    render_proc = lambda do |items, options|
      if items && !items.empty?
        render_to_string(:partial => 'system_groups/events/more_items', :locals => {:cycle_extra => false, :group => @group, :jobs=> items})
      else
        "<tr><td>" + _("No events matching your search criteria.") + "</td></tr>"
      end
    end
    search = params[:search]
    render_panel_direct(Job, {:no_search_history => true, :render_list_proc => render_proc},
                        search, params[:offset], [:id, 'desc'],
                        :filter => {:job_owner_id => [@group.id], :task_owner_type => SystemGroup.class.name},
                        :load => true,
                        :simple_query => "#{search}")
  end

  protected

  def find_group
    @group = SystemGroup.find(params[:system_group_id])
  end

  helper_method :jobs
  def jobs(page_size = current_user.page_size)
    @group.jobs.order('id desc').limit(page_size)
  end

  helper_method :total_events_length
  def total_events_length
    @group.jobs.length
  end
end
