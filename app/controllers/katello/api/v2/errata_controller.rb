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

    private

    def resource_class
      # since it's Errata and not Erratum
      Katello::Errata
    end

    def filter_by_content_view_filter(filter)
      ids = filter.erratum_rules.map(&:errata_id)
      options = sort_params
      options[:filters] = [:terms => { :errata_id_exact => ids }]
      item_search(resource_class, params, options)
    end
  end
end
