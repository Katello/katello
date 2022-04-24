module Katello
  class Api::V2::ContentViewFiltersController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_editable_content_view, :only => [:create, :update, :destroy]
    before_action :find_readable_content_view, :only => [:show, :index, :auto_complete_search]
    before_action :find_filter, :except => [:index, :create, :auto_complete_search]
    wrap_parameters :include => (ContentViewFilter.attribute_names + %w(repository_ids))

    api :get, "/content_views/:content_view_id/filters", N_("list filters")
    api :get, "/content_view_filters", N_("list filters")
    param_group :search, Api::V2::ApiController
    param :content_view_id, :number, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("filter content view filters by name")
    param :types, Array, :desc => N_("types of filters")
    add_scoped_search_description_for(ContentViewFilter)
    def index
      respond(:collection => scoped_search(index_relation.distinct, :name, :asc))
    end

    def index_relation
      query = ContentViewFilter.where(:content_view_id => (@view || ContentView.readable))
      query = query.where(:name => params[:name]) if params[:name]
      if params[:types]
        types = params[:types].collect do |type|
          ::Katello::ContentViewFilter.class_for(type)
        end
        query = query.where("#{::Katello::ContentViewFilter.table_name}.type IN (?)", types)
      end
      query
    end

    api :post, "/content_views/:content_view_id/filters", N_("create a filter for a content view")
    api :post, "/content_view_filters", N_("create a filter for a content view")
    param :content_view_id, :number, :desc => N_("content view identifier"), :required => true
    param :name, String, :desc => N_("name of the filter"), :required => true
    param :type, String, :desc => N_("type of filter (e.g. deb, rpm, package_group, erratum, erratum_id, erratum_date, docker, modulemd)"), :required => true
    param :original_packages, :bool, :desc => N_("add all packages without errata to the included/excluded list. " \
                                                       "(package filter only)")
    param :original_module_streams, :bool, :desc => N_("add all module streams without errata to the included/excluded list. " \
                                                       "(module stream filter only)")
    param :inclusion, :bool, :desc => N_("specifies if content should be included or excluded, default: inclusion=false")
    param :repository_ids, Array, :desc => N_("list of repository ids")
    param :description, String, :desc => N_("description of the filter")
    def create
      params[:type] = "erratum" if (params[:type] == "erratum_date" || params[:type] == "erratum_id")
      filter = ContentViewFilter.create_for(params[:type], filter_params.merge(:content_view => @view))
      respond :resource => filter
    end

    api :get, "/content_views/:content_view_id/filters/:id", N_("show filter info")
    api :get, "/content_view_filters/:id", N_("show filter info")
    param :content_view_id, :number, :desc => N_("content view identifier")
    param :id, :number, :desc => N_("filter identifier"), :required => true
    def show
      respond :resource => @filter
    end

    api :put, "/content_views/:content_view_id/filters/:id", N_("update a filter")
    api :put, "/content_view_filters/:id", N_("update a filter")
    param :content_view_id, :number, :desc => N_("content view identifier")
    param :id, :number, :desc => N_("filter identifier"), :required => true
    param :name, String, :desc => N_("new name for the filter")
    param :original_packages, :bool, :desc => N_("add all packages without errata to the included/excluded list. " \
                                                       "(package filter only)")
    param :original_module_streams, :bool, :desc => N_("add all module streams without errata to the included/excluded list. " \
                                                       "(module stream filter only)")
    param :inclusion, :bool, :desc => N_("specifies if content should be included or excluded, default: inclusion=false")
    param :repository_ids, Array, :desc => N_("list of repository ids")
    param :description, String, :desc => N_("description of the filter"), :required => false

    def update
      @filter.update!(filter_params)
      respond :resource => @filter
    end

    api :delete, "/content_views/:content_view_id/filters/:id", N_("delete a filter")
    api :delete, "/content_view_filters/:id", N_("delete a filter")
    param :content_view_id, :number, :desc => N_("content view identifier")
    param :id, :number, :desc => N_("filter identifier"), :required => true
    def destroy
      @filter.destroy
      respond_for_show :resource => @filter
    end

    api :put, "/content_views/:content_view_id/filters/:id/remove_filter_rules", N_("bulk delete filter rules")
    api :put, "/content_view_filters/:id/remove_filter_rules", N_("bulk delete filter rules")
    param :content_view_id, :number, :desc => N_("content view identifier")
    param :id, :number, :desc => N_("filter identifier"), :required => true
    param :rule_ids, Array, of: :number, :desc => N_("filter identifiers"), :required => true
    def remove_filter_rules
      rule_clazz = ContentViewFilter.rule_class_for(@filter)
      rule_clazz.where(id: params[:rule_ids]).try(:destroy_all)
      respond_for_show(resource: @filter)
    end

    api :put, "/content_views/:content_view_id/filters/:id/add_filter_rules", N_("bulk add filter rules")
    api :put, "/content_view_filters/:id/add_filter_rules", N_("bulk add filter rules")
    param :content_view_id, :number, :desc => N_("content view identifier")
    param :id, :number, :desc => N_("filter identifier"), :required => true
    param :rules_params, Array, :desc => N_("Rules to be added"), :required => false do
      param :name, Array, of: [String], :desc => N_("package, package group, or docker tag names")
      param :uuid, String, :desc => N_("package group: uuid")
      param :version, String, :desc => N_("package: version")
      param :architecture, String, :desc => N_("package: architecture")
      param :min_version, String, :desc => N_("package: minimum version")
      param :max_version, String, :desc => N_("package: maximum version")
      param :errata_id, String, :desc => N_("erratum: id")
      param :errata_ids, Array, :desc => N_("erratum: IDs or a select all object")
      param :start_date, String, :desc => N_("erratum: start date (YYYY-MM-DD)")
      param :end_date, String, :desc => N_("erratum: end date (YYYY-MM-DD)")
      param :types, Array, :desc => N_("erratum: types (enhancement, bugfix, security)")
      param :date_type, String, :desc => N_("erratum: search using the 'Issued On' or 'Updated On' column of the errata. Values are 'issued'/'updated'")
      param :module_stream_ids, Array, :desc => N_("module stream ids")
    end
    def add_filter_rules
      rule_clazz = ContentViewFilter.rule_class_for(@filter)
      rules = []
      rules_params[:rules_params].each do |rule_params|
        rules = (rule_params[:name] || []).map do |name|
          rule_clazz.create!(rule_params.except(:name).merge(:filter => @filter, name: name))
        end

        rules += (rule_params[:errata_ids] || []).map do |errata_id|
          rule_clazz.create!(rule_params.except(:errata_ids)
                                 .merge(filter: @filter, errata_id: errata_id))
        end
        if rule_params[:module_stream_ids]
          rules += (rule_params[:module_stream_ids] || []).map do |module_stream_id|
            rule_clazz.create!(rule_params.except(:module_stream_ids)
                                   .merge(filter: @filter, module_stream_id: module_stream_id))
          end
        end

        if rules.empty?
          rules = [rule_clazz.create!(rule_params.merge(:filter => @filter))]
        end
      end

      respond_for_show(resource: @filter)
    end

    private

    def find_readable_content_view
      @view = ContentView.readable.find_by(id: params[:content_view_id]) if params[:content_view_id]
      throw_resource_not_found(name: 'content view', id: params[:content_view_id]) if params[:content_view_id] && @view.nil?
    end

    def find_editable_content_view
      @view = ContentView.editable.find_by(id: params[:content_view_id]) if params[:content_view_id]
      throw_resource_not_found(name: 'content view', id: params[:content_view_id]) if params[:content_view_id] && @view.nil?
    end

    def find_filter
      if @view
        @filter = @view.filters.find_by(:id => params[:id])
      elsif params[:action] == 'show'
        @filter = ContentViewFilter.readable.find_by(id: params[:id])
        @view = @filter&.content_view
      else
        @filter = ContentViewFilter.editable.find_by(id: params[:id])
        @view = @filter&.content_view
      end
      fail HttpErrors::NotFound, _("Couldn't find ContentViewFilter with id=%s") % params[:id] unless @filter
    end

    def filter_params
      params.require(:content_view_filter).permit(:name, :inclusion, :original_packages, :original_module_streams, :description, :repository_ids => [])
    end

    def rules_params
      params.permit(:id, :content_view_id, :rules_params => [:uuid, :version, :min_version, :max_version, :architecture,
                                                             :errata_id, :start_date, :end_date, :date_type,
                                                             :types => [], :module_stream_ids => [], :errata_ids => [], name: []])
    end
  end
end
