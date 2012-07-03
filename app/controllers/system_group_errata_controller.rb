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

require 'util/errata'

class SystemGroupErrataController < ApplicationController

  helper SystemErrataHelper

  before_filter :find_group, :only =>[:install, :index, :items, :status]
  before_filter :authorize

  def section_id
    'systems'
  end

  def rules
    edit_group = lambda{SystemGroup.find(params[:system_group_id]).systems_editable?}
    read_group = lambda{SystemGroup.find(params[:system_group_id]).systems_readable?}
    {
      :index => read_group,
      :items => read_group,
      :install => edit_group,
      :status => edit_group
    }
  end

  def index
    offset = current_user.page_size
    render :partial=>"system_groups/errata/index", :layout => "tupane_layout",
           :locals=>{:system=>@group, :editable => @group.systems_editable?, :offset => offset}
  end

  def items
    offset = params[:offset]
    filter_type = params[:filter_type] if params[:filter_type]
    errata_state = params[:errata_state] if params[:errata_state]
    chunk_size = current_user.page_size
    errata, errata_systems, total_count, results_count = get_errata(offset.to_i, offset.to_i+chunk_size, filter_type, errata_state)
        
    rendered_html = render_to_string(:partial=>"systems/errata/items", :locals => { :errata => errata,
                                                                                    :errata_systems => errata_systems,
                                                                                    :editable => @group.systems_editable? })

    render :json => {:html => rendered_html,
                      :results_count => results_count,
                      :total_count => total_count,
                      :current_count => errata.length + offset.to_i }
  end

  def install
    errata_ids = params[:errata_ids]
    job = @group.install_errata(errata_ids)
    
    notice _("Errata scheduled for install.")
    render :text => job.id
  rescue Exception => error
    errors error
    render :text => error, :status => :bad_request
  end

  def status
    if params[:id]
      jobs = @group.refreshed_jobs.joins(:task_statuses).where(
          'jobs.id' => params[:id], 'task_statuses.task_type' => [:errata_install])
    else
      jobs = @group.refreshed_jobs.joins(:task_statuses).where(
          'task_statuses.task_type' => [:errata_install], 'task_statuses.state' => [:waiting, :running])
    end
    render :json => jobs
  end

  private

  include SortColumnList
  include Katello::Errata

  def get_errata start, finish, filter_type="All", errata_state="outstanding"
    types = [Glue::Pulp::Errata::SECURITY, Glue::Pulp::Errata::ENHANCEMENT, Glue::Pulp::Errata::BUGZILLA]
    errata_state = errata_state || "outstanding"
    filter_type = filter_type || "All"    

    errata_hash = {} # {id => erratum}
    errata_system_hash = {} # {id => [system_name]}

    # build a hash of all errata across all systems in the group
    @group.systems.each do |system|
      errata = system.errata
      errata.each do |erratum|
        errata_hash[erratum.id] = erratum
        errata_system_hash[erratum.id] ||= []
        errata_system_hash[erratum.id] << system.name
      end
    end
    errata_list = errata_hash.values
    total_errata_count = errata_list.length

    errata_list = filter_by_type(errata_list, filter_type)
    errata_list = filter_by_state(errata_list, errata_state)
    
    filtered_errata_count = errata_list.length

    errata_list = errata_list.sort { |a,b|
      a.id.downcase <=> b.id.downcase
    }

    errata_list = errata_list[start...finish]

    return errata_list, errata_system_hash, total_errata_count, filtered_errata_count
  end

  def find_group
    @group = SystemGroup.find(params[:system_group_id])
  end

end
