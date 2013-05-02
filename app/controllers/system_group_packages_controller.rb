
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

class SystemGroupPackagesController < ApplicationController

  helper SystemPackagesHelper

  before_filter :find_group
  before_filter :authorize

  def section_id
    'systems'
  end

  def rules
    edit_group = lambda{SystemGroup.find(params[:system_group_id]).systems_editable?}
    read_group = lambda{SystemGroup.find(params[:system_group_id]).systems_readable?}

    {
      :index => read_group,
      :add => edit_group,
      :remove => edit_group,
      :update => edit_group,
      :package_status => edit_group
    }
  end

  def index
    actions = [:package_install, :package_update, :package_remove,
               :package_group_install, :package_group_remove,
               :package_group_update]
    jobs = @group.refreshed_jobs.joins(:task_statuses).where(
        'task_statuses.task_type' => actions, 'task_statuses.state' => [:waiting, :running])

    render :partial=>"system_groups/packages/index",
           :locals=>{:jobs => jobs, :editable => @group.systems_editable?}
  end

  def add
    if !params[:packages].blank?
      # user entered one or more package names (as comma-separated list) in the content box
      packages = Util::Package.validate_package_list_format(params[:packages])

      if packages
        job = @group.install_packages packages
        notify.success _("Install of Packages '%{packages}' scheduled for System Group '%{name}'.") % {:packages => params[:packages], :name => @group.name}
      else
        notify.error _("One or more errors found in Package names '%s'.") % params[:packages]
        render :text => '' and return
      end

    elsif !params[:groups].blank?
      # user entered one or more package group names (as comma-separated list) in the content box
      groups = params[:groups].split(/ *, */ )
      job = @group.install_package_groups groups
      notify.success _("Install of Package Groups '%{groups}' scheduled for System Group '%{name}'.") % {:groups => params[:groups], :name => @group.name}
    else
      notify.error _("Empty request received to install Packages or Package Groups for System Group '%s'.") %
                       @group['name']
      render :text => '' and return
    end

    render :partial => 'system_groups/packages/items',
           :locals => { :editable           => @group.systems_editable?,
                        :group_id           => @group.id,
                        :job                => job,
                        :include_tr_shading => false }
  rescue Errors::SystemGroupEmptyException => e
    if !params[:packages].blank?
      notify.error _("Install of Packages '%{packages}' scheduled for System Group '%{name}' failed.  Reason: %{message}") % {:packages => params[:packages], :name => @group.name, :message => e.message}
    elsif !params[:groups].blank?
      notify.error _("Install of Package Groups '%{groups}' scheduled for System Group '%{name}' failed.  Reason: %{message}") % {:groups => params[:groups], :name => @group.name, :message => e.message}
    end
    render :text => '' and return
  end

  def remove
    if !params[:packages].blank?
      # user entered one or more package names (as comma-separated list) in the content box
      packages = Util::Package.validate_package_list_format(params[:packages])

      if packages
        job = @group.uninstall_packages packages
        notify.success _("Uninstall of Packages '%{packages}' scheduled for System Group '%{name}'.") % {:packages => params[:packages], :name => @group.name}
      else
        notify.error _("One or more errors found in Package names '%s'.") % params[:packages]
        render :text => '' and return
      end

    elsif !params[:groups].blank?
      # user entered one or more package group names (as comma-separated list) in the content box
      groups = params[:groups].split(/ *, */ )
      job = @group.uninstall_package_groups groups
      notify.success _("Uninstall of Package Groups '%{groups}' scheduled for System Group '%{name}'.") %
        {:group => groups.join(','), :name => @group.name}
    else
      notify.error _("Empty request received to uninstall Packages or Package Groups for System Group '%s'.") %
                       @group['name']
      render :text => '' and return
    end

    render :partial => 'system_groups/packages/items', :locals => {:editable => @group.systems_editable?,
                                                                   :group_id => @group.id, :job => job,
                                                                   :include_tr_shading => false}
  rescue Errors::SystemGroupEmptyException => e
    if !params[:packages].blank?
      notify.error _("Uninstall of Packages '%{packages}' scheduled for System Group '%{name}' failed.  Reason: %{message}") % {:packages => params[:packages], :name => @group.name, :message => e.message}
    elsif !params[:groups].blank?
      notify.error _("Uninstall of Package Groups '%{groups}' scheduled for System Group '%{name}' failed.  Reason: %{message}") % {:groups => params[:groups], :name => @group.name, :message => e.message}
    end
    render :text => '' and return
  end

  def update
    if !params[:packages].blank?
      # user entered one or more package names (as comma-separated list) in the content box
      packages = Util::Package.validate_package_list_format(params[:packages])

      if packages
        job = @group.update_packages packages
        notify.success _("Update of Packages '%{packages}' scheduled for System Group '%{name}'.") % {:packages => params[:packages], :name => @group.name}
      else
        notify.error _("One or more errors found in Package names '%s'.") % params[:packages]
        render :text => '' and return
      end

    elsif !params[:groups].blank?
      # user entered one or more package group names (as comma-separated list) in the content box
      groups = params[:groups].split(/ *, */ )
      job = @group.update_package_groups groups
      notify.success _("Update of Package Groups '%{groups}' scheduled for System Group '%{name}'.") %
        {:groups => groups.join(','), :name => @group.name}
    else
      notify.error _("Empty request received to update Packages or Package Groups for System Group '%s'.") %
                       @group['name']
      render :text => '' and return
    end

    render :partial => 'system_groups/packages/items',
           :locals  => { :editable           => @group.systems_editable?,
                         :group_id           => @group.id,
                         :job                => job,
                         :include_tr_shading => false }

  rescue Errors::SystemGroupEmptyException => e
    if !params[:packages].blank?
      notify.error _("Update of Packages '%{packages}' scheduled for System Group '%{group}' failed.  Reason: %{message}") % {:packages => params[:packages], :group => @group.name, :message => e.message}
    elsif !params[:groups].blank?
      notify.error _("Update of Package Groups '%{groups}' scheduled for System Group '%{name}' failed.  Reason: %{message}") % {:groups => params[:groups], :name => @group.name, :message => e.message}
    end
    render :text => '' and return
  end

  def package_status
    # retrieve the status for the actions initiated by the client
    response = []
    jobs = @group.refreshed_jobs.where('jobs.id' => params[:id])
    jobs.each do |job|
      status_html = render_to_string(:template => 'system_groups/packages/_status', :layout => false,
                                     :locals => {:group_id => @group.id, :id => job.id, :state => job.state,
                                                 :status_message => job.status_message})

      response << {:id => job.id, :status_html => status_html}
    end

    render :json => response
  end

  private

  def find_group
    @group = SystemGroup.find(params[:system_group_id])
  end
end
