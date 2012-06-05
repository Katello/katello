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

class Api::SystemPackagesController < Api::ApiController
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

  # install packages remotely
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, "/systems/:system_id/packages", "Create a system package"
  param :groups, :undef
  param :packages, :undef
  def create
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task = @system.install_packages(packages)
      render :json => task.task_status, :status => 202
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task = @system.install_package_groups(groups)
      render :json => task.task_status, :status => 202
    end
  end

  # update packages remotely
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PUT, "/systems/:system_id/packages", "Update a system package"
  param :packages, :undef
  def update
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task = @system.update_packages(packages)
      render :json => task.task_status, :status => 202
    end
  end

  # uninstall packages remotely
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, "/systems/:system_id/packages", "Destroy a system package"
  param :groups, :undef
  param :packages, :undef
  def destroy
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task = @system.uninstall_packages(packages)
      render :json => task.task_status, :status => 202
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task = @system.uninstall_package_groups(groups)
      render :json => task.task_status, :status => 202
    end
  end

  protected

  def find_system
    @system = System.first(:conditions => {:uuid => params[:system_id]})
    raise HttpErrors::NotFound, _("Couldn't find system '#{params[:system_id]}'") if @system.nil?
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
