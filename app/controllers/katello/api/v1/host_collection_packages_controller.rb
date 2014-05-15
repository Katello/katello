# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
class Api::V1::HostCollectionPackagesController < Api::V1::ApiController
  resource_description do
    description <<-DOC
      methods for handling packages on host collection level
    DOC

    param :organization_id, :number, :desc => N_("oranization identifier"), :required => true
    param :host_collection_id, :identifier, :desc => N_("host_collection identifier"), :required => true

    api_version 'v1'
    api_version 'v2'
  end

  respond_to :json

  before_filter :find_host_collection, :only => [:create, :update, :destroy]
  before_filter :authorize
  before_filter :require_packages_or_groups, :only => [:create, :destroy]

  def rules
    edit_content_hosts = lambda { @host_collection.content_hosts_editable? }

    {
      :create  => edit_content_hosts,
      :update  => edit_content_hosts,
      :destroy => edit_content_hosts,
    }
  end

  api :POST, "/organizations/:organization_id/host_collections/:host_collection_id/packages", N_("Install packages remotely")
  param_group :packages_or_groups, Api::V1::SystemPackagesController
  def create
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = @host_collection.install_packages(packages)
      respond_for_async :resource => task
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task   = @host_collection.install_package_groups(groups)
      respond_for_async :resource => task
    end
  end

  api :PUT, "/organizations/:organization_id/host_collections/:host_collection_id/packages", N_("Update packages remotely")
  param_group :packages_or_groups, Api::V1::SystemPackagesController
  def update
    if params[:packages]
      params[:packages] = [] if params[:packages] == 'all'
      packages = validate_package_list_format(params[:packages])
      task     = @host_collection.update_packages(packages)
      respond_for_async :resource => task
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task   = @host_collection.install_package_groups(groups)
      respond_for_async :resource => task
    end
  end

  api :DELETE, "/organizations/:organization_id/host_collections/:host_collection_id/packages", N_("Uninstall packages remotely")
  param_group :packages_or_groups, Api::V1::SystemPackagesController
  def destroy
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = @host_collection.uninstall_packages(packages)
      respond_for_async :resource => task
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task   = @host_collection.uninstall_package_groups(groups)
      respond_for_async :resource => task
    end
  end

  protected

  def find_host_collection
    @host_collection = HostCollection.find(params[:host_collection_id])
    fail HttpErrors::NotFound, _("Couldn't find host collection '%s'") % params[:host_collection_id] if @host_collection.nil?
    @host_collection
  end

  def valid_package_name?(package_name)
    package_name =~ /^[a-zA-Z\-\.\_\+\,]+$/
  end

  def validate_package_list_format(packages)
    packages.each do |package_name|
      if !valid_package_name?(package_name)
        fail HttpErrors::BadRequest.new(_("%s is not a valid package name") % package_name)
      end
    end

    return packages
  end

  def require_packages_or_groups
    if params.slice(:packages, :groups).values.size != 1
      fail HttpErrors::BadRequest.new(_("Either packages or groups must be provided"))
    end
  end

  def extract_group_names(groups)
    groups.map do |group|
      group.gsub(/^@/, "")
    end
  end
end
end
