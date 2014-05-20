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
class Api::V2::PackagesController < Api::V2::ApiController

  before_filter :find_repository
  before_filter :find_package, :only => [:show]

  api :GET, "/repositories/:repository_id/packages", "List packages"
  param :repository_id, :identifier, :desc => "Repository id to list packages for"
  param_group :search, Api::V2::ApiController
  def index
    options = {
      :filters => [{:term => {:repoids => [@repo.pulp_id]}}],
    }
    params[:sort_by] = 'nvra'

    items = item_search(Package, params, options)
    items[:results] = items[:results].map{|pkg| Package.new(pkg.as_json)}
    respond(:collection => items)
  end

  api :GET, "/repositories/:repository_id/packages/:id", "Show a package"
  param :repository_id, :number, :desc => "Repository id"
  param :id, String, :desc => "Package id"
  def show
    respond :resource => @package
  end

  private

  def find_repository
    @repo = Repository.find(params[:repository_id])
    fail HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
  end

  def find_package
    @package = Package.find(params[:id])
    fail HttpErrors::NotFound, _("Package with id '%s' not found") % params[:id] if @package.nil?
    # and check ownership of it
    fail HttpErrors::NotFound, _("Package '%s' not found within the repository") % params[:id] unless @package.repoids.include? @repo.pulp_id
  end

end
end
