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

class Api::V1::SystemPackagesController < Api::V1::ApiController

  resource_description do
    param :system_id, :identifier, :desc => "system identifier", :required => true
  end

  respond_to :json

  before_filter :find_system, :only => [:create, :update, :destroy]
  before_filter :authorize
  before_filter :require_packages_or_groups, :only => [:create, :destroy]
  before_filter :require_packages_only, :only => [:update]

  def rules
    edit_system = lambda { @system.editable? or User.consumer? }

    {
      :create => edit_system,
      :update => edit_system,
      :destroy => edit_system,
    }
  end

  def_param_group :packages_or_groups do
    param :packages, Array, :desc => "List of package names", :required => false
    param :groups, Array, :desc => "List of package group names", :required => false
  end

  # install packages remotely
  api :POST, "/systems/:system_id/packages", "Install packages remotely"
  param_group :packages_or_groups
  def create
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task = @system.install_packages(packages)
      render :json => task, :status => 202
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task = @system.install_package_groups(groups)
      render :json => task, :status => 202
    end
  end

  # update packages remotely
  api :PUT, "/systems/:system_id/packages", "Update packages remotely"
  param :packages, Array, :desc => "list of packages names"
  def update
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task = @system.update_packages(packages)
      render :json => task, :status => 202
    end
  end

  # uninstall packages remotely
  api :DELETE, "/systems/:system_id/packages", "Uninstall packages remotely"
  param_group :packages_or_groups
  def destroy
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task = @system.uninstall_packages(packages)
      render :json => task, :status => 202
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task = @system.uninstall_package_groups(groups)
      render :json => task, :status => 202
    end
  end

  protected

  def find_system
    @system = System.first(:conditions => {:uuid => params[:system_id]})
    raise HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
    @system
  end

  def valid_package_name?(package_name)
    package_name =~ /^[a-zA-Z\-\.\_\+\,]+$/
  end

  def validate_package_list_format(packages)
    packages.each do |package_name|
      if not valid_package_name?(package_name)
        raise HttpErrors::BadRequest.new(_("%s is not a valid package name") % package_name)
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
      group.gsub(/^@/,"")
    end
  end
end
