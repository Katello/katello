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
class SystemGroupErrataController < Katello::ApplicationController

  helper SystemErrataHelper

  before_filter :find_group, :only => [:install, :index, :items, :errata_status]
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
      :errata_status => edit_group
    }
  end

  def index
    offset = current_user.page_size
    render :partial => "katello/system_groups/errata/index",
           :locals => {:system => @group, :editable => @group.systems_editable?, :offset => offset}
  end

  def items
    filter_type = params[:filter_type]

    if filter_type && filter_type != 'All'
      filter_type.downcase!
    else
      filter_type = nil
    end

    errata = @group.errata(filter_type)

    system_uuids = errata.flat_map{|e| e.applicable_consumers}.uniq
    system_hash = {}
    System.where(:uuid => system_uuids).select([:uuid, :name]).each do |sys|
      system_hash[sys.uuid] = sys
    end

    errata.each do |erratum|
      erratum.applicable_consumers = erratum.applicable_consumers.map{|uuid| {:name => system_hash[uuid].name, :uuid => uuid }}
    end

    rendered_html = render_to_string(:partial => "katello/systems/errata/items",
                                     :locals => { :errata => errata,
                                                  :editable => @group.systems_editable? })

    render :json => {:html => rendered_html,
                     :results_count => errata.length,
                     :total_count => errata.length,
                     :current_count => errata.length  }
  end

  def install
    errata_ids = params[:errata_ids]
    job = @group.install_errata(errata_ids)

    notify.success _("Install of Errata '%{errata}' scheduled for System Group '%{group}'.") % {:errata => params[:errata_ids], :group => @group.name}
    render :text => job.id

  rescue Errors::SystemGroupEmptyException => e
    notify.error _("Install of Errata '%{errata}' scheduled for System Group '%{group}' failed.  Reason: %{message}") % {:errata => params[:errata_ids], :group => @group.name, :message => e.message}

    render :text => ''
  end

  def errata_status
    if params[:id]
      jobs = @group.refreshed_jobs.joins(:task_statuses).where(
          "#{Katello::Job.table_name}.id" => params[:id],
          "#{Katello::TaskStatus.table_name}.task_type" => [:errata_install])
    else
      jobs = @group.refreshed_jobs.joins(:task_statuses).where(
          "#{Katello::TaskStatus.table_name}.task_type" => [:errata_install],
          "#{Katello::TaskStatus.table_name}.state" => [:waiting, :running])
    end
    render :json => jobs
  end

  private

  def find_group
    @group = SystemGroup.find(params[:system_group_id])
  end

end
end
