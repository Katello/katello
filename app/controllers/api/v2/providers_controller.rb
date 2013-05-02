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


class Api::V2::ProvidersController < Api::V1::ProvidersController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :provider do
    param :provider, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "Provider name", :required => true
      param :description, String, :desc => "Provider description"
      param :repository_url, String, :desc => "Repository URL"
    end
  end

  api :POST, "/organizations/:organization_id/providers", "Create a provider"
  param :organization_id, :identifier, :desc => "Organization identifier", :required => true
  param_group :provider
  def create
    super
  end

  api :DELETE, "/providers/:id", "Destroy a provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def destroy
    #
    # TODO: these should really be done as validations, but the orchestration engine currently converts them into OrchestrationExceptions
    #
    raise HttpErrors::BadRequest, _("Provider cannot be deleted since one of its products or repositories has already been promoted. Using a changeset, please delete the repository from existing environments before deleting it.") if @provider.repositories.any? { |r| r.promoted? }

    @provider.destroy
    respond
  end

  api :PUT, "/providers/:id/refresh_products", "Refresh products for Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def refresh_products
    super
  end

end
