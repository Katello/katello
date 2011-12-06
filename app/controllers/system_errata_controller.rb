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

  before_filter :find_system, :only =>[:update, :index, :more_errata, :items]
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
      :more_errata => read_system,
      :update => edit_system
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
    debugger
    offset = params[:offset]
    chunk_size = current_user.page_size
    errata = get_errata(offset, offset+chunk_size)
    
    render :partial => "systems/errata/items", :locals => { :errata => errata }    
  end

  def update
  end

  private

  include SortColumnList

  def get_errata start, finish
    types = [Glue::Pulp::Errata::SECURITY, Glue::Pulp::Errata::ENHANCEMENT, Glue::Pulp::Errata::BUGZILLA]

    to_ret = []
    (rand(85) + 10).times{ |num|
      errata = OpenStruct.new
      errata.errata_id = "RHSA-2011-01-#{num}"
      errata.errata_type = types[rand(3)]
      errata.product = "Red Hat Enterprise Linux 6.0"
      to_ret << errata
    }
    
    errata = to_ret.sort { |a,b|
      a.errata_id.downcase <=> b.errata_id.downcase 
    }
    total_errata = errata.length
    to_ret = to_ret[start...finish]
    
    return to_ret, total_errata
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
