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

class Api::V1::SystemGroupPackagesController < Api::V1::ApiController
  resource_description do
    description <<-DOC
      methods for handling packages on system group level
    DOC

    param :organization_id, :identifier, :desc => "oranization identifier", :required => true
    param :system_group_id, :identifier, :desc => "system_group identifier", :required => true

    api_version 'v1'
    api_version 'v2'
  end

  respond_to :json

  before_filter :find_group, :only => [:create, :update, :destroy]
  before_filter :authorize
  before_filter :require_packages_or_groups, :only => [:create, :destroy]

  def rules
    edit_systems = lambda { @group.systems_editable? }

    {
      :create => edit_systems,
      :update => edit_systems,
      :destroy => edit_systems,
    }
  end

  api :POST, "/organizations/:organization_id/system_groups/:system_group_id/packages", "Install packages remotely"
  param_group :packages_or_groups, Api::V1::SystemPackagesController
  def create
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      job = @group.install_packages(packages)
      respond_for_async :resource => task
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      job = @group.install_package_groups(groups)
      respond_for_async :resource => task
    end
  end

  api :PUT, "/organizations/:organization_id/system_groups/:system_group_id/packages", "Update packages remotely"
  param_group :packages_or_groups, Api::V1::SystemPackagesController
  def update
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      job = @group.update_packages(packages)
      respond_for_async :resource => task
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      job = @group.install_package_groups(groups)
      respond_for_async :resource => task
    end
  end

  api :DELETE, "/organizations/:organization_id/system_groups/:system_group_id/packages", "Uninstall packages remotely"
  param_group :packages_or_groups, Api::V1::SystemPackagesController
  def destroy
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      job = @group.uninstall_packages(packages)
      respond_for_async :resource => task
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      job = @group.uninstall_package_groups(groups)
      respond_for_async :resource => task
    end
  end

  protected

  def find_group
    @group = SystemGroup.find(params[:system_group_id])
    raise HttpErrors::NotFound, _("Couldn't find system group '%s'") % params[:system_group_id] if @group.nil?
    @group
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
      raise HttpErrors::BadRequest.new(_("Either packages or groups must be provided"))
    end
  end

  def extract_group_names(groups)
    groups.map do |group|
      group.gsub(/^@/,"")
    end
  end
end
