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

class SystemPackagesController < ApplicationController
  include AutoCompleteSearch

  before_filter :find_system, :except =>[:index, :auto_complete_search, :items, :environments, :env_items, :bulk_destroy, :new, :create]
  before_filter :authorize

  def section_id
    'systems'
  end

  def rules
    edit_system = lambda{System.find(params[:system_id]).editable?}
    read_system = lambda{System.find(params[:system_id]).readable?}

    {
      :packages => read_system,
      :more_packages => read_system,
      :add => edit_system,
      :remove => edit_system,
      :update => edit_system
    }
  end

  def add
    # TODO: action for adding packages

    # the packages to be added will be provided as a string of comma separated names (ignore leading/trailing spaces)
    packages = params[:packages].split(/ *, */ ) unless params[:packages].nil?

    # the package groups to be added will be provided as a string of comma separated names (ignore leading/trailing spaces)
    groups = params[:groups].split(/ *, */ ) unless params[:groups].nil?

    render :text => ''
  end

  def remove
    # TODO: action for removing packages
    render :text => ''
  end

  def update
    # TODO: action for updating packages
    render :text => ''
  end

  def packages
    offset = current_user.page_size
    packages = @system.simple_packages.sort {|a,b| a.nvrea.downcase <=> b.nvrea.downcase}
    if packages.length > 0
      if params.has_key? :pkg_order
        if params[:pkg_order].downcase == "desc"
          packages.reverse!
        end
      end
      packages = packages[0...offset]
    else
      packages = []
    end
    render :partial=>"packages", :layout => "tupane_layout", :locals=>{:system=>@system, :packages => packages,
                                                                       :offset => offset, :editable => @system.editable?}
  end

  def more_packages
    #grab the current user setting for page size
    size = current_user.page_size
    #what packages are available?
    packages = @system.simple_packages.sort {|a,b| a.nvrea.downcase <=> b.nvrea.downcase}
    if packages.length > 0
      #check for the params offset (start of array chunk)
      if params.has_key? :offset
        offset = params[:offset].to_i
      else
        offset = current_user.page_size
      end
      if params.has_key? :pkg_order
        if params[:pkg_order].downcase == "desc"
          #reverse if order is desc
          packages.reverse!
        end
      end
      if params.has_key? :reverse
        packages = packages[0...params[:reverse].to_i]
      else
        packages = packages[offset...offset+size]
      end
    else
      packages = []
    end
    render :partial=>"more_packages", :locals=>{:system=>@system, :packages => packages, :offset=> offset}
  end

  private

  include SortColumnList

  def find_system
    @system = System.find(params[:system_id])
  end

  def controller_display_name
    return _('system')
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
