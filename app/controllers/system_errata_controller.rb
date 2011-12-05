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

  before_filter :find_system, :only =>[:update, :index, :more_errata]
  before_filter :authorize

  def section_id
    'systems'
  end

  def rules
    edit_system = lambda{System.find(params[:system_id]).editable?}
    read_system = lambda{System.find(params[:system_id]).readable?}

    {
      :index => read_system,
      :more_errata => read_system,
      :update => edit_system
    }
  end

  def index
    errata_temp = OpenStruct.new
    errata_temp.id = "Test Errata"
    errata_temp.product = "Red Hat Enterprise Linux 6.0"
    errata_temp.errata_type = Glue::Pulp::Errata::BUGZILLA
    errata = [errata_temp]
    render :partial=>"systems/errata/index", :layout => "tupane_layout", :locals=>{:system=>@system, :errata => errata,
                                                                       :editable => @system.editable?, :offset => 25}
  end

  def more_errata
  end

  def update
  end

  private

  include SortColumnList

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
