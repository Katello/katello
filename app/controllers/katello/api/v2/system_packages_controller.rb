#
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
class Api::V2::SystemPackagesController < Api::V2::ApiController

  before_filter :require_packages_or_groups, :only => [:install, :remove]
  before_filter :require_packages_only, :only => [:upgrade]
  before_filter :find_system

  resource_description do
    api_version 'v2'
    api_base_url "/katello/api"
  end

  def_param_group :packages_or_groups do
    param :packages, Array, :desc => N_("List of package names"), :required => false
    param :groups, Array, :desc => N_("List of package group names"), :required => false
  end

  api :PUT, "/systems/:system_id/packages/install", N_("Install packages remotely"), :deprecated => true
  param :system_id, :identifier, :required => true, :desc => N_("UUID of the content-host")
  param_group :packages_or_groups
  def install
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = async_task(::Actions::Katello::System::Package::Install, @system, packages)
      respond_for_async :resource => task
      return
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task   = async_task(::Actions::Katello::System::PackageGroup::Install, @system, groups)
      respond_for_async :resource => task
    end

  end

  api :PUT, "/systems/:system_id/packages/upgrade", N_("Update packages remotely"), :deprecated => true
  param :system_id, :identifier, :required => true, :desc => N_("UUID of the content-host")
  param :packages, Array, :desc => N_("list of packages names"), :required => true
  def upgrade
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = async_task(::Actions::Katello::System::Package::Update, @system, packages)
      respond_for_async :resource => task
    end
  end

  api :PUT, "/systems/:system_id/packages/upgrade_all", N_("Update packages remotely"), :deprecated => true
  param :system_id, :identifier, :required => true, :desc => N_("UUID of the content-host")
  def upgrade_all
    task     = async_task(::Actions::Katello::System::Package::Update, @system, [])
    respond_for_async :resource => task
  end

  api :PUT, "/systems/:system_id/packages/remove", N_("Uninstall packages remotely"), :deprecated => true
  param :system_id, :identifier, :required => true, :desc => N_("UUID of the content-host")
  param_group :packages_or_groups
  def remove
    if params[:packages]
      packages = validate_package_list_format(params[:packages])
      task     = async_task(::Actions::Katello::System::Package::Remove, @system, packages)
      respond_for_async :resource => task
      return
    end

    if params[:groups]
      groups = extract_group_names(params[:groups])
      task   = async_task(::Actions::Katello::System::PackageGroup::Remove, @system, groups)
      respond_for_async :resource => task
    end
  end

  private

  def find_system
    @system = System.first(:conditions => { :uuid => params[:system_id] })
    fail HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
    @system
  end

  def valid_package_name?(package_name)
    package_name =~ /^[a-zA-Z0-9\-\.\_\+\,]+$/
  end

  def validate_package_list_format(packages)
    packages.each do |package|
      if !valid_package_name?(package) && !package.is_a?(Hash)
        fail HttpErrors::BadRequest.new(_("%s is not a valid package name") % package)
      end
    end

    return packages
  end

  def require_packages_or_groups
    if params.slice(:packages, :groups).values.size != 1
      fail HttpErrors::BadRequest.new(_("Either packages or groups  must be provided"))
    end
  end

  def require_packages_only
    if params[:groups]
      fail HttpErrors::BadRequest.new(_("This action doesn't support pacakge groups"))
    end

    unless params[:packages]
      fail HttpErrors::BadRequest.new(_("Packages must be provided"))
    end
  end

  def extract_group_names(groups)
    groups.map do |group|
      group.gsub(/^@/, "")
    end
  end

end
end
