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

class SystemPackagesController < ApplicationController

  before_filter :find_system
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
      :update => edit_system,
      :package_status => edit_system
    }
  end

  def add
    if !params[:packages].blank?
      # user entered one or more package names (as comma-separated list) in the content box
      packages = Util::Package.validate_package_list_format(params[:packages])

      if packages
        task = @system.install_packages packages
        notify.success _("Install of Packages '%{p}' scheduled for System '%{s}'.") %
                           { :s => @system['name'], :p => params[:packages] }
      else
        notify.error _("One or more errors found in Package names '%s'.") % params[:packages]
        render :text => ''
        return
      end

    elsif !params[:groups].blank?
      # user entered one or more package group names (as comma-separated list) in the content box
      groups = params[:groups].split(/ *, */)
      task = @system.install_package_groups groups
      notify.success _("Install of Package Groups '%{g}' scheduled for System '%{s}'.") %
                         { :s => @system['name'], :g => params[:groups] }
    else
      notify.error _("Empty request received to install Packages or Package Groups for System '%s'.") %
                       @system['name']
      render :text => ''
      return
    end

    render :text => task.id
  end

  def remove
    if !params[:package].nil?
      # user selected one or more packages from the list of installed packages
      packages = params[:package].keys
      task = @system.uninstall_packages packages
      notify.success _("Uninstall of Packages '%{p}' scheduled for System '%{s}'.") %
                         { :s => @system['name'], :p => packages.join(',') }

    elsif !params[:packages].blank?
      # user entered one or more package names (as comma-separated list) in the content box
      packages = Util::Package.validate_package_list_format(params[:packages])

      if packages
        task = @system.uninstall_packages packages
        notify.success _("Uninstall of Packages '%{p}' scheduled for System '%{s}'.") %
                           { :s => @system['name'], :p => params[:packages] }
      else
        notify.error _("One or more errors found in Package names '%s'.") % params[:packages]
        render :text => ''
        return
      end

    elsif !params[:groups].blank?
      # user entered one or more package group names (as comma-separated list) in the content box
      groups = params[:groups].split(/ *, */)
      task = @system.uninstall_package_groups groups
      notify.success _("Uninstall of Package Groups '%{p}' scheduled for System '%{s}'.") %
                         { :s => @system['name'], :p => groups.join(',') }
    else
      notify.error _("Empty request received to uninstall Packages or Package Groups for System '%s'.") %
                       @system['name']
      render :text => ''
      return
    end

    render :text => task.id
  end

  def update
    packages = nil
    if !params[:package].nil?
      # user selected one or more packages from the list of installed packages
      packages = params[:package].keys
    end

    task = @system.update_packages packages

    if packages.nil?
      notify.success _("Update of all packages scheduled for System '%s'.") % @system['name']
    else
      notify.success _("Update of Packages '%{p}' scheduled for System '%{s}'.") %
                         { :s => @system['name'], :p => params[:package] }
    end

    render :text => task.id
  end

  def packages
    if @system.class == Hypervisor
      render :partial => "systems/hypervisor",
             :locals => {:system => @system,
                       :message => _("Hypervisors do not have packages")}
      return
    end

    offset = current_user.page_size
    packages = @system.simple_packages.sort {|a, b| a.nvrea.downcase <=> b.nvrea.downcase}
    total_packages = packages.length
    if total_packages > 0
      if params.has_key? :pkg_order
        if params[:pkg_order].downcase == "desc"
          packages.reverse!
        end
      end
    else
      packages = []
    end

    package_tasks = @system.tasks.where(:task_type => [:package_install, :package_update, :package_remove],
                                        :state => [:waiting, :running])
    group_tasks = @system.tasks.where(:task_type => [:package_group_install, :package_group_remove],
                                      :state => [:waiting, :running])

    render :partial => "packages", :locals => {:system => @system, :packages => packages,
                                           :total_packages => total_packages,
                                                                       :package_tasks => package_tasks,
                                                                       :group_tasks => group_tasks,
                                                                       :offset => offset, :editable => @system.editable?}
  end

  def more_packages
    packages = @system.simple_packages.sort {|a, b| a.nvrea.downcase <=> b.nvrea.downcase}

    if params.has_key? :pkg_order
      if params[:pkg_order].downcase == "desc"
        packages.reverse!
      end
    end

    render :partial => "package_items", :locals => {:packages => packages, :package_tasks => nil,
                                                :group_tasks => nil, :offset => 0,
                                                :editable => @system.editable?}
  end

  def package_status
    # retrieve the status for the package actions initiated by the client
    statuses = @system.tasks.where(:id => params[:id],
                                   :task_type => [:package_install, :package_update, :package_remove,
                                                  :package_group_install, :package_group_remove])
    render :json => statuses
  end

  private

  include SortColumnList

  def find_system
    @system = System.find(params[:system_id])
  end

  def controller_display_name
    return 'system'
  end

  def sort_order_limit(systems)
    sort_columns(COLUMNS, systems) if params[:order]
    offset = params[:offset].to_i if params[:offset]
    offset ||= 0
    last = offset + current_user.page_size
    last = systems.length if last > systems.length
    systems[offset...last]
  end
end
