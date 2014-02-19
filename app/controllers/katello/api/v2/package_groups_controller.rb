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
class Api::V2::PackageGroupsController < Api::V2::ApiController

  before_filter :find_repository
  before_filter :authorize
  before_filter :find_package_group, :only => [:show]

  def rules
    readable = lambda { @repo.environment.contents_readable? && @repo.product.readable? }
    {
        :index  => readable,
        :show   => readable
    }
  end

  api :GET, "/package_groups", "List package groups"
  api :GET, "/repositories/:repository_id/package_groups", "List package groups"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  def index
    options = sort_params
    options[:filters] = [{ :term => { :repo_id => @repo.pulp_id } }]

    @search_service.model = PackageGroup
    respond(:collection => item_search(PackageGroup, params, options))
  end

  api :GET, "/package_groups/:id", "Show a package group"
  api :GET, "/repositories/:repository_id/package_groups/:id", "Show a package group"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  param :id, String, :desc => "package group identifier", :required => true
  def show
    respond :resource => @package_group
  end

  private

  def find_repository
    @repo = Repository.find(params[:repository_id]) if params[:repository_id]
  end

  def find_package_group
    @package_group = PackageGroup.find(params[:id])
    fail HttpErrors::NotFound, _("Package group with id '%s' not found") % params[:id] if @package_group.nil?
  end
end
end
