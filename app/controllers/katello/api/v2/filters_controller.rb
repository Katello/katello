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
class Api::V2::FiltersController < Api::V2::ApiController

  before_filter :find_content_view
  before_filter :find_filter, :except => [:index, :create]
  before_filter :load_search_service, :only => [:index, :available_errata, :available_package_groups]
  before_filter :authorize

  wrap_parameters :include => (Filter.attribute_names + %w(repository_ids))

  def rules
    view_readable = lambda { @view.readable? }
    view_editable = lambda { @view.editable? }

    {
        :index                    => view_readable,
        :create                   => view_editable,
        :show                     => view_readable,
        :update                   => view_editable,
        :destroy                  => view_editable,
        :available_errata         => view_readable,
        :available_package_groups => view_readable
    }
  end

  api :GET, "/content_views/:content_view_id/filters", "List filters"
  api :GET, "/filters", "List filters"
  param :content_view_id, :identifier, :desc => "content view identifier", :required => true
  def index
    options = sort_params
    options[:load_records?] = true
    options[:filters] = [{ :terms => { :id => @view.filter_ids } }]

    @search_service.model = Filter
    respond(:collection => item_search(Filter, params, options))
  end

  api :POST, "/content_views/:content_view_id/filters", "Create a filter for a content view"
  api :POST, "/filters", "Create a filter for a content view"
  param :content_view_id, :identifier, :desc => "content view identifier", :required => true
  param :name, String, :desc => "name of the filter", :required => true
  param :type, String, :desc => "type of filter (e.g. rpm, package_group, erratum)", :required => true
  param :inclusion, :bool, :desc => "specifies if content should be included or excluded, default: inclusion=false"
  param :repository_ids, Array, :desc => "list of repository ids"
  def create
    filter = Filter.create_for(params[:type], filter_params.merge(:content_view => @view))
    respond :resource => filter
  end

  api :GET, "/content_views/:content_view_id/filters/:id", "Show filter info"
  api :GET, "/filters/:id", "Show filter info"
  param :content_view_id, :identifier, :desc => "content view identifier"
  param :id, :identifier, :desc => "filter identifier", :required => true
  def show
    respond :resource => @filter
  end

  api :PUT, "/content_views/:content_view_id/filters/:id", "Update a filter"
  api :PUT, "/filters/:id", "Update a filter"
  param :content_view_id, :identifier, :desc => "content view identifier"
  param :id, :identifier, :desc => "filter identifier", :required => true
  param :name, String, :desc => "new name for the filter"
  param :inclusion, :bool, :desc => "specifies if content should be included or excluded, default: inclusion=false"
  param :repository_ids, Array, :desc => "list of repository ids"
  def update
    @filter.update_attributes!(filter_params)
    respond :resource => @filter
  end

  api :DELETE, "/content_views/:content_view_id/filters/:id", "Delete a filter"
  api :DELETE, "/filters/:id", "Delete a filter"
  param :content_view_id, :identifier, :desc => "content view identifier"
  param :id, :identifier, :desc => "filter identifier", :required => true
  def destroy
    @filter.destroy
    respond :resource => @filter
  end

  api :GET, "/content_views/:content_view_id/filters/:id/available_errata",
      "Get errata that are available to be added to the filter"
  api :GET, "/filters/:id/available_errata",
      "Get errata that are available to be added to the filter"
  param :content_view_id, :identifier, :desc => "content view identifier"
  param :id, :identifier, :desc => "filter identifier", :required => true
  def available_errata
    current_errata_ids = @filter.erratum_rules.map(&:errata_id)
    repo_ids = @filter.applicable_repos.pluck(:pulp_id)
    search_filters = [{ :terms => { :repoids => repo_ids } },
                      { :not => { :terms => { :errata_id_exact => current_errata_ids } } }]
    options = { :filters => search_filters }

    collection = item_search(Errata, params, options)
    collection[:results] = collection[:results].map do |erratum|
      Katello::Errata.new_from_search(erratum.as_json)
    end

    respond_for_index :template => '../errata/index',
                      :collection => collection
  end

  api :GET, "/content_views/:content_view_id/filters/:id/available_package_groups",
      "Get package groups that are available to be added to the filter"
  api :GET, "/filters/:id/available_package_groups",
      "Get package groups that are available to be added to the filter"
  param :content_view_id, :identifier, :desc => "content view identifier"
  param :id, :identifier, :desc => "filter identifier", :required => true
  def available_package_groups
    current_ids = @filter.package_group_rules.map(&:name)
    repo_ids = @filter.applicable_repos.pluck(:pulp_id)
    search_filters = [{ :terms => { :repo_id => repo_ids } },
                      { :not => { :terms => { :name => current_ids } } }]
    options = { :filters => search_filters }

    respond_for_index :template => '../package_groups/index',
                      :collection => item_search(PackageGroup, params, options)
  end

  private

  def find_content_view
    @view = ContentView.find(params[:content_view_id]) if params[:content_view_id]
  end

  def find_filter
    if @view
      @filter = @view.filters.find_by_id(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find Filter with id=%s") % params[:id] unless @filter
    else
      @filter = Filter.find(params[:id])
      @view = @filter.content_view
    end
  end

  def filter_params
    params.require(:filter).permit(:name, :inclusion, :repository_ids => [])
  end

end
end
