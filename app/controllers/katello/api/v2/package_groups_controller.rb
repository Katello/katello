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
  before_filter :find_content_view, :only => [:index]
  before_filter :find_filter, :only => [:index]
  before_filter :authorize
  before_filter :find_package_group, :only => [:show]

  def rules
    readable = lambda do
      (@filter && @filter.content_view.readable?) ||
      (@repo && @repo.environment.contents_readable? && @repo.product.readable?)
    end
    {
        :index => readable,
        :show  => readable
    }
  end

  api :GET, "/package_groups", "List package groups"
  api :GET, "/content_views/:content_view_id/filters/:filter_id/package_groups", "List package groups"
  api :GET, "/content_view_filters/:content_view_filter_id/package_groups", "List package groups"
  api :GET, "/repositories/:repository_id/package_groups", "List package groups"
  param :content_view_id, :identifier, :desc => "content view identifier"
  param :filter_id, :identifier, :desc => "content view filter identifier"
  param :content_view_filter_id, :identifier, :desc => "content view filter identifier"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  def index
    collection = if @repo && !@repo.puppet?
                   filter_by_repo_id @repo.pulp_id
                 elsif @filter
                   filter_by_name @filter.package_group_rules.map(&:name)
                 else
                   filter_by_repo_id
                 end

    respond(:collection => collection)
  end

  api :GET, "/package_groups/:id", "Show a package group"
  api :GET, "/repositories/:repository_id/package_groups/:id", "Show a package group"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  param :id, String, :desc => "package group identifier", :required => true
  def show
    respond :resource => @package_group
  end

  private

  def filter_by_name(names)
    options = sort_params
    options[:filters] = [{ :terms => { :name => names } }]
    item_search(PackageGroup, params, options)
  end

  def filter_by_repo_id(repo_id = [])
    options = sort_params
    options[:filters] = [{ :term => { :repo_id => repo_id } }]
    item_search(PackageGroup, params, options)
  end

  def find_content_view
    @view = ContentView.find(params[:content_view_id]) if params[:content_view_id]
  end

  def find_filter
    if @view
      @filter = @view.filters.find_by_id(params[:filter_id])
      fail HttpErrors::NotFound, _("Couldn't find Filter with id=%s") % params[:filter_id] unless @filter
    else
      @filter = ContentViewFilter.find(params[:content_view_filter_id]) if params[:content_view_filter_id]
    end
  end

  def find_repository
    @repo = Repository.find(params[:repository_id]) if params[:repository_id]
  end

  def find_package_group
    @package_group = PackageGroup.find(params[:id])
    fail HttpErrors::NotFound, _("Package group with id '%s' not found") % params[:id] if @package_group.nil?
  end
end
end
