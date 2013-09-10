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

class Api::V2::SystemPackagesController < Api::V2::ApiController

  before_filter :require_packages_or_groups, :only => [:install, :remove]
  before_filter :require_packages_only, :only => [:upgrade, :upgrade_all]
  before_filter :find_system
  before_filter :authorize

  def rules
    edit_system = lambda { @system.editable? || User.consumer? }
    {
      :install => edit_system,
      :upgrade  => edit_system,
      :upgrade_all  => edit_system,
      :remove  => edit_system
    }
  end

  def_param_group :packages_or_groups do
    param :packages, Array, :desc => "List of package names", :required => false
    param :groups, Array, :desc => "List of package group names", :required => false
  end

  api :POST, "/systems/:system_id/packages/install", "Install packages remotely"
  param_group :packages_or_groups
  def install
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = @system.install_packages(packages)
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task   = @system.install_package_groups(groups)
    end

    respond_for_show :template => 'system_task', :resource => task
  end

  # update packages remotely
  api :PUT, "/systems/:system_id/packages/upgrade", "Update packages remotely"
  param :packages, Array, :desc => "list of packages names"
  def upgrade
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = @system.update_packages(packages)
      respond_for_show :template => 'system_task', :resource => task
    end
  end

  api :PUT, "/systems/:system_id/packages/upgrade_all", "Update packages remotely"
  def upgrade_all
    task     = @system.update_packages([])
    respond_for_show :template => 'system_task', :resource => task
  end

  api :POST, "/systems/:system_id/packages/remove", "Uninstall packages remotely"
  param_group :packages_or_groups
  def remove
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = @system.uninstall_packages(packages)
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task   = @system.uninstall_package_groups(groups)
    end

    respond_for_show :template => 'system_task', :resource => task
  end

  private

  def find_system
    @system = System.first(:conditions => { :uuid => params[:system_id] })
    raise HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
    @system
  end

  def valid_package_name?(package_name)
    package_name =~ /^[a-zA-Z\-\.\_\+\,]+$/
  end

  def validate_package_list_format(packages)
    packages.each do |package|
      if !valid_package_name?(package) && !package.is_a?(Hash)
        raise HttpErrors::BadRequest.new(_("%s is not a valid package name") % package)
      end
    end

    return packages
  end

  def require_packages_or_groups
    if params.slice(:packages, :groups).values.size != 1
      raise HttpErrors::BadRequest.new(_("Either packages or groups  must be provided"))
    end
  end

  def require_packages_only
    if params[:groups]
      raise HttpErrors::BadRequest.new(_("This action doesn't support pacakge groups"))
    end

    unless params[:packages]
      raise HttpErrors::BadRequest.new(_("Packages must be provided"))
    end
  end

  def extract_group_names(groups)
    groups.map do |group|
      group.gsub(/^@/, "")
    end
  end

end
