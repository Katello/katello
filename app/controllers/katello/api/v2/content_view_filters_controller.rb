module Katello
  class Api::V2::ContentViewFiltersController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_filter :find_content_view
    before_filter :find_filter, :except => [:index, :create, :auto_complete_search]

    wrap_parameters :include => (ContentViewFilter.attribute_names + %w(repository_ids))

    api :get, "/content_views/:content_view_id/filters", N_("list filters")
    api :get, "/content_view_filters", N_("list filters")
    param_group :search, Api::V2::ApiController
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("filter content view filters by name")
    def index
      respond(:collection => scoped_search(index_relation.uniq, :name, :asc))
    end

    def index_relation
      query = ContentViewFilter.where(:content_view_id => (@view || ContentView.readable))
      query = query.where(:name => params[:name]) unless params[:name].blank?
      query
    end

    api :post, "/content_views/:content_view_id/filters", N_("create a filter for a content view")
    api :post, "/content_view_filters", N_("create a filter for a content view")
    param :content_view_id, :identifier, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("name of the filter"), :required => true
    param :type, String, :desc => N_("type of filter (e.g. rpm, package_group, erratum)"), :required => true
    param :original_packages, :bool, :desc => N_("add all packages without errata to the included/excluded list. " \
                                                       "(package filter only)")
    param :inclusion, :bool, :desc => N_("specifies if content should be included or excluded, default: inclusion=false")
    param :repository_ids, Array, :desc => N_("list of repository ids")
    param :description, String, :desc => N_("description of the filter")
    def create
      filter = ContentViewFilter.create_for(params[:type], filter_params.merge(:content_view => @view))
      respond :resource => filter
    end

    api :get, "/content_views/:content_view_id/filters/:id", N_("show filter info")
    api :get, "/content_view_filters/:id", N_("show filter info")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    def show
      respond :resource => @filter
    end

    api :put, "/content_views/:content_view_id/filters/:id", N_("update a filter")
    api :put, "/content_view_filters/:id", N_("update a filter")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    param :name, String, :desc => N_("new name for the filter")
    param :original_packages, :bool, :desc => N_("add all packages without errata to the included/excluded list. " \
                                                       "(package filter only)")
    param :inclusion, :bool, :desc => N_("specifies if content should be included or excluded, default: inclusion=false")
    param :repository_ids, Array, :desc => N_("list of repository ids")
    def update
      @filter.update_attributes!(filter_params)
      respond :resource => @filter
    end

    api :delete, "/content_views/:content_view_id/filters/:id", N_("delete a filter")
    api :delete, "/content_view_filters/:id", N_("delete a filter")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :id, :identifier, :desc => N_("filter identifier"), :required => true
    def destroy
      @filter.destroy
      respond_for_show :resource => @filter
    end

    private

    def find_content_view
      @view = ContentView.find(params[:content_view_id]) if params[:content_view_id]
    end

    def find_filter
      if @view
        @filter = @view.filters.find_by(:id => params[:id])
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
