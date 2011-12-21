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

class SystemErrataController < ApplicationController

  before_filter :find_system, :only =>[:install, :index, :items, :status]
  before_filter :authorize

  def section_id
    'systems'
  end

  def rules
    edit_system = lambda{System.find(params[:system_id]).editable?}
    read_system = lambda{System.find(params[:system_id]).readable?}

    {
      :index => read_system,
      :items => read_system,
      :install => edit_system,
      :status => edit_system
    }
  end

  def index
    chunk_size = current_user.page_size
    errata, total_errata = get_errata(0, chunk_size)
    
    render :partial=>"systems/errata/index", :layout => "tupane_layout", :locals=>{:system=>@system, :errata => errata,
                                                                       :editable => @system.editable?, :offset => 25,
                                                                       :total_errata => total_errata }
  end

  def items
    offset = params[:offset]
    filter_type = params[:filter_type] if params[:filter_type]
    errata_state = params[:errata_state] if params[:errata_state]
    chunk_size = current_user.page_size
    errata, total_errata = get_errata(offset.to_i, offset.to_i+chunk_size, filter_type, errata_state)
        
    render :partial => "systems/errata/items", :locals => { :errata => errata, :editable => @system.editable? }    
  end

  def install
    errata_ids = params[:errata_ids]
    task = @system.install_errata(errata_ids)
    
    notice _("Errata scheduled for install.")
    render :text => task.task_status.uuid
  rescue Exception => error
    errors error
    Rails.logger.info error.backtrace.join("\n")
    render :text => error, :status => :bad_request
  end

  def status
    if params[:uuid]
      statuses = @system.tasks.where(:uuid => params[:uuid], :task_type => [:errata_install])
    else
      statuses = @system.tasks.where(:task_type => [:errata_install], :state => [:waiting, :running])
    end
    render :json => statuses
  end


  private

  include SortColumnList

  def get_errata start, finish, filter_type="All", errata_state="outstanding"
    types = [Glue::Pulp::Errata::SECURITY, Glue::Pulp::Errata::ENHANCEMENT, Glue::Pulp::Errata::BUGZILLA]

    errata_list = @system.errata

    errata_list = filter_by_type(errata_list, filter_type)
    errata_list = filter_by_state(errata_list, errata_state)
    
    errata_list = errata_list.sort { |a,b|
      a.id.downcase <=> b.id.downcase 
    }
    
    total_errata = errata_list.length
    errata_list = errata_list[start...finish]
    
    return errata_list, total_errata
  end

  def filter_by_type errata_list, filter_type
    filtered_list = []
    
    if filter_type != "All"
      pulp_filter_type = get_pulp_filter_type(filter_type)
      
      errata_list.each{ |errata| 
        if errata.type == pulp_filter_type
          filtered_list << errata
        end
      }
    else
      filtered_list = errata_list
    end
    
    return filtered_list
  end

  def get_pulp_filter_type filter_type
    if filter_type == "Bug"
      return Glue::Pulp::Errata::BUGZILLA
    elsif filter_type == "Enhancement"
      return Glue::Pulp::Errata::ENHANCEMENT
    elsif filter_type == "Security"
      return Glue::Pulp::Errata::SECURITY
    end
  end

  def filter_by_state errata_list, errata_state
    if errata_state == "applied"
      return []
    else
      return errata_list
    end
  end

  def find_system
    @system = System.find(params[:system_id])
  end

  def sort_order_limit systems
      sort_columns(COLUMNS, systems) if params[:order]
      offset = params[:offset].to_i if params[:offset]
      offset ||= 0
      last = offset + current_user.page_size
      last = systems.length if last > systems.length
      systems[offset...last]
  end

end
