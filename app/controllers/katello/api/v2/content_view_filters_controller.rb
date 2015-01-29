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
  class Api::V2::ContentViewFiltersController < Api::V2::ApiController
    before_filter :find_content_view
    before_filter :find_filter, :except => [:index, :create]
    before_filter :load_search_service, :only => [:index, :available_errata, :available_package_groups]

    wrap_parameters :include => (ContentViewFilter.attribute_names + %w(repository_ids))

    api :GET, "/content_views/:content_view_id/filters", N_("List filters")
    api :GET, "/content_view_filters", N_("List filters")
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("Filter content view filters by name")
    def index
      params.require(:content_view_id)
      options = sort_params
      options[:load_records?] = true
      options[:filters] = [{ :terms => { :id => @view.filter_ids } }]
      options[:filters] << {:term => {:name => params[:name]}} if params[:name]

      @search_service.model = ContentViewFilter
      respond(:collection => item_search(ContentViewFilter, params, options))
    end

    api :POST, "/content_views/:content_view_id/filters", N_("Create a filter for a content view")
    api :POST, "/content_view_filters", N_("Create a filter for a content view")
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("name of the filter"), :required => true
    param :type, String, :desc => N_("type of filter (e.g. rpm, package_group, erratum)"), :required => true
    param :original_packages, :bool, :desc => N_("Add all packages without Errata to the included/excluded list. " \
                                                       "(Package Filter only)")
    param :inclusion, :bool, :desc => N_("specifies if content should be included or excluded, default: inclusion=false")
    param :repository_ids, Array, :desc => N_("list of repository ids")
    param :description, String, :desc => N_("description of the filter")
    def create
      filter = ContentViewFilter.create_for(params[:type], filter_params.merge(:content_view => @view))
      respond :resource => filter
    end

    api :GET, "/content_views/:content_view_id/filters/:id", N_("Show filter info")
    api :GET, "/content_view_filters/:id", N_("Show filter info")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    def show
      respond :resource => @filter
    end

    api :PUT, "/content_views/:content_view_id/filters/:id", N_("Update a filter")
    api :PUT, "/content_view_filters/:id", N_("Update a filter")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    param :name, String, :desc => N_("new name for the filter")
    param :original_packages, :bool, :desc => N_("Add all packages without Errata to the included/excluded list. " \
                                                       "(Package Filter only)")
    param :inclusion, :bool, :desc => N_("specifies if content should be included or excluded, default: inclusion=false")
    param :repository_ids, Array, :desc => N_("list of repository ids")
    def update
      @filter.update_attributes!(filter_params)
      respond :resource => @filter
    end

    api :DELETE, "/content_views/:content_view_id/filters/:id", N_("Delete a filter")
    api :DELETE, "/content_view_filters/:id", N_("Delete a filter")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    def destroy
      @filter.destroy
      respond_for_show :resource => @filter
    end

    api :GET, "/content_views/:content_view_id/filters/:id/available_errata",
        N_("Get errata that are available to be added to the filter")
    api :GET, "/content_view_filters/:id/available_errata",
        N_("Get errata that are available to be added to the filter")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    param :types, Array, :desc => N_("Errata types array \\['security', 'bugfix', 'enhancement'\\]")
    param :start_date, DateTime, :desc => N_("Start date that Errata was issued on to filter by")
    param :end_date, DateTime, :desc => N_("End date that Errata was issued on to filter by")
    def available_errata
      current_errata_ids = @filter.erratum_rules.map(&:errata_id)

      scoped = Erratum.in_repositories(@filter.applicable_repos)
      scoped = scoped.where('errata_id not in (?)', current_errata_ids) unless current_errata_ids.empty?
      scoped = scoped.where('issued  >= ?', params[:start_date]) if params[:start_date]
      scoped = scoped.where('issued  <= ?', params[:end_date]) if params[:end_date]
      scoped = scoped.of_type(params[:types]) if params[:types]

      respond_for_index :template => '../errata/index',
                        :collection => scoped_search(scoped, 'issued', 'desc', Erratum)
    end

    api :GET, "/content_views/:content_view_id/filters/:id/available_package_groups",
        N_("Get package groups that are available to be added to the filter")
    api :GET, "/content_view_filters/:id/available_package_groups",
        N_("Get package groups that are available to be added to the filter")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    def available_package_groups
      current_ids = @filter.package_group_rules.map(&:uuid)
      repo_ids = @filter.applicable_repos.readable.pluck("#{Repository.table_name}.pulp_id")
      search_filters = [{ :terms => { :repo_id => repo_ids } }]
      search_filters << { :not => { :terms => { :id => current_ids } } } unless current_ids.blank?

      options = sort_params
      options[:filters] = search_filters

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
        fail HttpErrors::NotFound, _("Couldn't find ContentViewFilter with id=%s") % params[:id] unless @filter
      else
        @filter = ContentViewFilter.find(params[:id])
        @view = @filter.content_view
      end
    end

    def filter_params
      params.require(:content_view_filter).permit(:name, :inclusion, :original_packages, :description, :repository_ids => [])
    end
  end
end
