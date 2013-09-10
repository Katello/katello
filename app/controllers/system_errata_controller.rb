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

class SystemErrataController < ApplicationController

  before_filter :find_system, :only => [:install, :index, :items, :errata_status]
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
      :errata_status => edit_system
    }
  end

  def index
    if @system.class == Hypervisor
      render :partial => "systems/hypervisor",
             :locals => {:system => @system,
                       :message => _("Hypervisors do not have errata")}
      return
    end

    offset = current_user.page_size

    render :partial => "systems/errata/index",
           :locals => {:system => @system, :editable => @system.editable?, :offset => offset}
  end

  def items
    offset = params[:offset]
    filter_type = params[:filter_type] if params[:filter_type]
    errata_state = params[:errata_state] if params[:errata_state]
    chunk_size = current_user.page_size
    errata, total_count, results_count = get_errata(offset.to_i, offset.to_i + chunk_size, filter_type, errata_state)

    return render_bad_parameters unless errata

    rendered_html = render_to_string(:partial => "systems/errata/items", :locals => { :errata => errata, :editable => @system.editable? })
    render :json => {:html => rendered_html,
                      :results_count => results_count,
                      :total_count => total_count,
                      :current_count => errata.length + offset.to_i }
  end

  def install
    task = @system.install_errata(params[:errata_ids])

    notify.success _("Errata scheduled for install.")
    render :text => task.id
  end

  def errata_status
    if params[:id]
      statuses = @system.tasks.where('task_statuses.id' => params[:id], :task_type => [:errata_install])
    else
      statuses = @system.tasks.where(:task_type => [:errata_install], :state => [:waiting, :running])
    end
    render :json => statuses
  end

  private

  include SortColumnList
  include Util::Errata

  def get_errata(start, finish, filter_type = "All", errata_state = "outstanding")
    errata_state = errata_state || "outstanding"
    filter_type = filter_type || "All"

    errata_list = @system.errata
    total_errata_count = errata_list.length

    errata_list = filter_by_type(errata_list, filter_type)
    errata_list = filter_by_state(errata_list, errata_state)

    filtered_errata_count = errata_list.length

    errata_list = errata_list.sort_by{ |a| a.errata_id.downcase}
    errata_list = errata_list[start...finish]

    return errata_list, total_errata_count, filtered_errata_count
  end

  def find_system
    @system = System.find(params[:system_id])
  end

end
