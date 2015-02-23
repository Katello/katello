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
  class Api::V2::SystemErrataController < Api::V2::ApiController
    before_filter :find_system
    before_filter :find_errata_ids, :only => :apply

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    api :PUT, "/systems/:system_id/errata/apply", N_("Schedule errata for installation"), :deprecated => true
    param :system_id, :identifier, :desc => N_("System UUID"), :required => true
    param :errata_ids, Array, :desc => N_("List of Errata ids to install"), :required => true
    def apply
      task = async_task(::Actions::Katello::System::Erratum::Install, @system, params[:errata_ids])
      respond_for_async :resource => task
    end

    api :GET, "/systems/:system_id/errata/:id", N_("Retrieve a single errata for a system"), :deprecated => true
    param :system_id, :identifier, :desc => N_("System UUID"), :required => true
    param :id, String, :desc => N_("Errata id of the erratum (RHSA-2012:108)"), :required => true
    def show
      errata = Erratum.find_by_errata_id(params[:id])
      respond_for_show :resource => errata
    end

    private

    def find_system
      @system = System.first(:conditions => { :uuid => params[:system_id] })
      fail HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
      @system
    end

    def find_errata_ids
      missing = params[:errata_ids] - Erratum.where(:errata_id => params[:errata_ids]).pluck(:errata_id)
      fail HttpErrors::NotFound, _("Couldn't find errata ids '%s'") % missing.to_sentence if missing.any?
    end
  end
end
