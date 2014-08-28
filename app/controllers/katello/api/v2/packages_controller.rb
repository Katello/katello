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
  before_filter :find_content_view_version, :only => [:index]
  before_filter :find_package, :only => [:show]

  api :GET, "/repositories/:repository_id/packages", "List packages"
  api :GET, "/packages", "List packages"
  param :repository_id, :identifier, :desc => "Repository id to list packages for"
  param :content_view_version_id, :identifier, :desc => "Version id to list packages for"
  param_group :search, Api::V2::ApiController
  def index
    if @content_view_version
      repoids = @content_view_version.archived_repos.map(&:pulp_id)
    elsif @repo
      repoids = [@repo.pulp_id]
    else
      fail HttpErrors::BadRequest, _("Missing required repository or content view version search params.")
    end
    options = {
      :filters => [{:term => {:repoids => repoids}}],
    }
    params[:sort_by] = 'nvra'

    items = item_search(Package, params, options)
    items[:results] = items[:results].map{|pkg| Package.new(pkg.as_json)}
    respond(:collection => items)
  end

  api :GET, "/repositories/:repository_id/packages/:id", "Show a package"
  api :GET, "/packages/:id", "Show a package"
  param :repository_id, :number, :desc => "Repository id"
  param :id, String, :desc => "Package id"
  def show
    respond :resource => @package
  end

  private

  def find_repository
    if params[:repository_id]
      @repo = Repository.readable.find_by_id(params[:repository_id])
      fail HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
    end
  end

  def find_content_view_version
    if params[:content_view_version_id]
      @content_view_version = ContentViewVersion.readable.find_by_id(params[:content_view_version_id])
      fail HttpErrors::NotFound, _("Couldn't find content view version '%s'") % params[:content_view_version_id] if @content_view_version.nil?
    end
  end

  def find_package
    @package = Package.find(params[:id])
    fail HttpErrors::NotFound, _("Package with id '%s' not found") % params[:id] if @package.nil?

    # and check ownership of it
    if @repo && !@package.repoids.include?(@repo.pulp_id)
      fail HttpErrors::NotFound, _("Package '%s' not found within the repository") % params[:id]
    end
  end

end
end
