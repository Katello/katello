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

  before_filter :find_repository, :only => [:index, :show]
  before_filter :find_content_view, :only => [:index]
  before_filter :find_content_view_version, :only => [:index]
  before_filter :find_filter, :only => [:index]
  before_filter :find_erratum, :only => [:show]

  api :GET, "/errata", N_("List errata")
  api :GET, "/content_views/:content_view_id/filters/:filter_id/errata", N_("List errata")
  api :GET, "/content_view_filters/:content_view_filter_id/errata", N_("List errata")
  api :GET, "/repositories/:repository_id/errata", N_("List errata")
  param :content_view_id, :identifier, :desc => N_("content view identifier")
  param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
  param :filter_id, :identifier, :desc => N_("content view filter identifier")
  param :content_view_filter_id, :identifier, :desc => N_("content view filter identifier")
  param :repository_id, :number, :desc => N_("repository identifier")
  def index
    collection = if @repo && !@repo.puppet?
                   filter_by_repoids [@repo.pulp_id]
                 elsif @filter
                   filter_by_errata_id @filter.erratum_rules.map(&:errata_id)
                 elsif @content_view_version
                   filter_by_content_view_version
                 else
                   filter_by_repoids
                 end

    respond(:collection => collection)
  end

  api :GET, "/errata/:id", N_("Show an erratum")
  api :GET, "/repositories/:repository_id/errata/:id", N_("Show an erratum")
  param :repository_id, :number, :desc => N_("repository identifier")
  param :id, String, :desc => N_("erratum identifier"), :required => true
  def show
    respond :resource => @erratum
  end

  private

  def filter_by_errata_id(ids)
    options = sort_params
    options[:filters] = [:terms => { :errata_id_exact => ids }]
    item_search(Errata, params, options)
  end

  def filter_by_repoids(repoids = [])
    options = sort_params
    options[:filters] = [{ :terms => { :repoids => repoids } }]
    item_search(Errata, params, options)
  end

  def filter_by_content_view_version
    filter_by_repoids(@content_view_version.archived_repos.map(&:pulp_id))
  end

  def find_content_view
    @view = ContentView.find(params[:content_view_id]) if params[:content_view_id]
  end

  def find_content_view_version
    if params[:content_view_version_id]
      @content_view_version = ContentViewVersion.readable.find(params[:content_view_version_id])
    end
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

  def find_erratum
    @erratum = Errata.find(params[:id])
    @erratum ||= Errata.find_by_errata_id(params[:id])
    fail HttpErrors::NotFound, _("Erratum with id '%s' not found") % params[:id] if @erratum.nil?
    fail HttpErrors::NotFound, _("Erratum '%s' not found within the repository") % params[:id] unless @repo.nil? || @erratum.repoids.include?(@repo.pulp_id)
    @erratum
  end
end
end
