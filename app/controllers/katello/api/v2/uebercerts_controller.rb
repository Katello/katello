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
class Api::V2::UebercertsController < Api::V2::ApiController

  before_filter :find_organization, :only => [:show]

  resource_description do
    api_version 'v2'
    api_base_url "#{Katello.config.url_prefix}/api"
  end

  api :GET, "/organizations/:organization_id/uebercert", N_("Show an ueber certificate for an organization")
  param :regenerate, :bool, :desc => N_("When set to 'True' certificate will be re-issued")
  def show
    @organization.generate_debug_cert if (params[:regenerate] || '').downcase == 'true'
    respond :resource => @organization.debug_cert
  end

end
end
