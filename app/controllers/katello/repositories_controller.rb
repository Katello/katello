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
class RepositoriesController < Katello::ApplicationController

  respond_to :html, :js

  def auto_complete_library
    # retrieve and return a list (array) of repo names in library that contain the 'term' that was passed in
    query = "name_autocomplete:#{params[:term]}"

    ids = []
    ids += Product.readable_repositories.pluck(:id) if Product.readable?
    ids += ContentView.readable_repositories.pluck(:library_instance_id)
    ids.uniq!

    repos = Repository.search do
      query do
        string query
      end
      filter :terms, {:id => ids}
    end

    render :json => (repos.map do |repo|
      label = _("%{repo} (Product: %{product})") % {:repo => repo.name, :product => repo.product}
      {:id => repo.id, :label => label, :value => repo.name}
    end)
  end

end
end
