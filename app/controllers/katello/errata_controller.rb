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

module Katello
class ErrataController < Katello::ApplicationController

  before_filter :lookup_errata, except: [:auto_complete]

  def short_details
    render :partial => "short_details"
  end

  def auto_complete
    repo_ids = readable_repos(:pulp_id)

    results = Errata.autocomplete_search("#{params[:term]}*", repo_ids)
    results = results.map { |erratum| {label: erratum.id_title, value: erratum.errata_id} }

    render :json => results
  end

  private

  def lookup_errata
    repo_ids = readable_repos(:pulp_id)
    @errata = Errata.find(params[:id])
    deny_access if (@errata.repoids & repo_ids).empty?
  end

  def readable_repos(attribute)
    repos = []
    repos += Product.readable_repositories.pluck(attribute)
    repos += ContentView.readable_repositories.pluck(attribute)
    repos
  end

end
end
