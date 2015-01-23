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
  class Api::V2::ErrataController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("an erratum"), :resource => "errata")
    include Katello::Concerns::Api::V2::RepositoryContentController
    include Katello::Concerns::Api::V2::RepositoryDbContentController

    api :GET, "/errata", N_("List errata")
    param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
    param :content_view_filter_id, :identifier, :desc => N_("content view filter identifier")
    param :repository_id, :number, :desc => N_("repository identifier")
    param :environment_id, :number, :desc => N_("environment identifier")
    param :cve, String, :desc => N_("CVE identifier")
    param :errata_restrict_applicable, :bool, :desc => N_("show only errata with one or more applicable systems")
    param :errata_restrict_installable, :bool, :desc => N_("show only errata with one or more installable systems")
    param_group :search, Api::V2::ApiController
    def index
      super
    end

    def custom_index_relation(collection)
      collection = filter_by_cve(params[:cve], collection) if params[:cve]
      if params[:errata_restrict_applicable] && params[:errata_restrict_applicable].to_bool
        collection = collection.applicable_to_systems(System.readable)
      end

      if params[:errata_restrict_installable] && params[:errata_restrict_installable].to_bool
        collection = collection.installable_for_systems(System.readable)
      end
      collection
    end

    private

    def filter_by_cve(cve, collection)
      collection.joins(:cves).where('katello_erratum_cves.cve_id' => cve)
    end

    def filter_by_content_view_filter(filter, collection)
      collection.where(:errata_id => filter.erratum_rules.pluck(:errata_id))
    end

    def default_sort
      %w(updated desc)
    end
  end
end
