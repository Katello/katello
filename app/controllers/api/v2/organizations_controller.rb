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

class Api::V2::OrganizationsController < Api::V1::OrganizationsController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  before_filter :find_organization, :only => [:show, :update, :destroy, :repo_discover,
                                              :auto_attach_all_systems, :cancel_repo_discover]

  before_filter :authorize

  def_param_group :organization do
    param :organization, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "name for the organization", :required => true, :action_aware => true
      param :description, String
    end
  end

  def rules
    hash = super
    edit_test   = lambda { @organization.editable? }

    hash[:cancel_repo_discover] = edit_test
    hash[:repo_discover] = edit_test
    hash
  end

  def param_rules
    rules = super
    rules[:create] = {:organization  => [:name, :description, :label]}
  end

  api :POST, "/organizations", "Create an organization"
  param_group :organization
  def create
    @organization = Organization.create!(params[:organization])
    respond
  end

  api :PUT, "/organizations/:label/repo_discover", "Discover Repositories"
  param :label, String, :desc => "Organization label"
  param :url, String, :desc => "base url to perform repo discovery on"
  def repo_discover
    fail _("url not defined.") if params[:url].blank?
    uuid, _ = Orchestrate.trigger(Orchestrate::Katello::RepositoryDiscover, params[:url])
    task = DynflowTask.find_by_uuid!(uuid)
    respond_for_async :resource => task
  end

  api :PUT, "/organizations/:label/cancel_repo_discover", "Cancel repository discovery"
  param :label, String, :desc => "Organization label"
  param :url, String, :desc => "base url to perform repo discovery on"
  def cancel_repo_discover
    # TODO: implement task canceling
    render :json => { message: "not implemented" }
  end

  api :GET, "/organizations/:label", "Show an organization"
  def show
    respond_for_show
  end

end
