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
class PackagesController < Katello::ApplicationController

  before_filter :lookup_package, except: [:auto_complete]

  def auto_complete
    repo_ids = readable_repos(:pulp_id)
    results = Package.autocomplete_name("#{params[:term]}*", repo_ids)

    render :json => results
  end

  def details
    render :partial => "details"
  end

  private

  def lookup_package
    repo_ids = readable_repos(:pulp_id)
    package_id = params[:id]
    @package = Package.find(package_id)
    fail _("Unable to find package %s") % package_id if @package.nil?
    deny_access if (@package.repoids & repo_ids).empty?
  end

  def readable_repos(attribute)
    repos = []
    repos += Product.readable_repositories.pluck(attribute)
    repos += ContentView.readable_repositories.pluck(attribute)
    repos
  end

end
end
