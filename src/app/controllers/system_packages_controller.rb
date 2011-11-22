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
    if !params[:packages].nil?
      # user entered one or more package names (as comma-separated list) in the content box
      packages = params[:packages].split(/ *, */ )
      @system.install_packages packages
      notice _("Install of Packages '%{p}' scheduled for System '%{s}'." % {:s => @system['name'], :p => params[:packages]})

    elsif !params[:groups].nil?
      # user entered one or more package group names (as comma-separated list) in the content box
      groups = params[:groups].split(/ *, */ )
      @system.install_package_groups groups
      notice _("Install of Package Groups '%{g}' scheduled for System '%{s}'." % {:s => @system['name'], :g => params[:groups]})

    else
      errors _("Empty request received to install Packages or Package Groups System '%{s}'." % {:s => @system['name']})
    end

    render :text => ''
  end

  def remove
    if !params[:package].nil?
      # user selected one or more packages from the list of installed packages
      packages = params[:package].keys
      @system.uninstall_packages packages
      notice _("Uninstall of Packages '%{p}' scheduled for System '%{s}'." % {:s => @system['name'], :p => packages.join(',')})

    elsif !params[:packages].nil?
      # user entered one or more package names (as comma-separated list) in the content box
      packages = params[:packages].split(/ *, */ )
      @system.uninstall_packages packages
      notice _("Uninstall of Packages '%{p}' scheduled for System '%{s}'." % {:s => @system['name'], :p => params[:packages]})

    elsif !params[:groups].nil?
      # user entered one or more package group names (as comma-separated list) in the content box
      groups = params[:groups].split(/ *, */ )
      @system.uninstall_package_groups groups
      notice _("Uninstall of Package Groups '%{p}' scheduled for System '%{s}'." % {:s => @system['name'], :p => groups.join(',')})

    else
      errors _("Empty request received to install Packages or Package Groups System '%{s}'." % {:s => @system['name']})
    end

    render :text => ''
  end

  def update
    packages = nil
    if !params[:package].nil?
      # user selected one or more packages from the list of installed packages
      packages = params[:package].keys
    end

    @system.update_packages packages

    if packages.nil?
      notice _("Update of all packages scheduled for System '%{s}'." % {:s => @system['name']})
    else
      notice _("Update of Packages '%{p}' scheduled for System '%{s}'." % {:s => @system['name'], :p => params[:package]})
    end

    render :text => ''
  end

  def packages
    offset = current_user.page_size
    packages = @system.simple_packages.sort {|a,b| a.nvrea.downcase <=> b.nvrea.downcase}
    total_packages = packages.length
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
                                                                       :total_packages => total_packages,
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
    render :partial=>"package_items", :locals=>{:packages => packages, :offset=> offset}
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
