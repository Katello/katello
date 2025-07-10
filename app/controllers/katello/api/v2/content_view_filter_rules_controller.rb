module Katello
  class Api::V2::ContentViewFilterRulesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :find_filter
    before_action :find_rule, :except => [:index, :create, :auto_complete_search]

    api :GET, "/content_view_filters/:content_view_filter_id/rules", N_("List filter rules")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :name, String, :desc => N_("name of the content view filter rule"), :required => false
    param :errata_id, String, :desc => N_("errata_id of the content view filter rule"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      respond(collection: scoped_search(index_relation, :id, :asc, resource_class: ContentViewFilter.rule_class_for(@filter)))
    end

    def index_relation
      query = ContentViewFilter.rule_class_for(@filter).where(content_view_filter_id: @filter.id)
      query = query.where(:name => params[:name]) if params[:name]
      query = query.where(:errata_id => params[:errata_id]) if params[:errata_id]
      query
    end

    def resource_class
      ContentViewFilter.rule_class_for(@filter)
    end

    api :POST, "/content_view_filters/:content_view_filter_id/rules",
        N_("Create a filter rule. The parameters included should be based upon the filter type.")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :name, Array, of: [String], :desc => N_("deb, package, package group, or docker tag names")
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
    param :allow_other_types, :bool, :desc => N_("erratum: allow types not matching a valid errata type")
    def create
      rule_clazz = ContentViewFilter.rule_class_for(@filter)

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

      if rules.many?
        respond_for_index(:collection => {:results => rules}, :template => 'index')
      else
        respond_for_create resource: rules.first
      end
    end

    api :GET, "/content_view_filters/:content_view_filter_id/rules/:id", N_("Show filter rule info")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :id, :number, :desc => N_("rule identifier"), :required => true
    def show
      respond :resource => @rule
    end

    api :PUT, "/content_view_filters/:content_view_filter_id/rules/:id",
        N_("Update a filter rule. The parameters included should be based upon the filter type.")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :id, :number, :desc => N_("rule identifier"), :required => true
    param :name, String, :desc => N_("package, package group, or docker tag: name")
    param :version, String, :desc => N_("package: version")
    param :architecture, String, :desc => N_("package: architecture")
    param :min_version, String, :desc => N_("package: minimum version")
    param :max_version, String, :desc => N_("package: maximum version")
    param :errata_id, String, :desc => N_("erratum: id")
    param :start_date, String, :desc => N_("erratum: start date (YYYY-MM-DD)")
    param :end_date, String, :desc => N_("erratum: end date (YYYY-MM-DD)")
    param :types, Array, :desc => N_("erratum: types (enhancement, bugfix, security)")
    param :allow_other_types, :bool, :desc => N_("erratum: allow types not matching a valid errata type")
    def update
      update_params = rule_params
      update_params[:name] = update_params[:name].first if update_params[:name]

      if [ContentViewPackageFilter::CONTENT_TYPE, ContentViewDebFilter::CONTENT_TYPE].include?(@rule.filter.content_type)
        update_params[:version] = "" unless rule_params[:version]
        update_params[:min_version] = "" unless rule_params[:min_version]
        update_params[:max_version] = "" unless rule_params[:max_version]
      end

      @rule.update!(update_params)
      respond :resource => @rule
    end

    api :DELETE, "/content_view_filters/:content_view_filter_id/rules/:id", N_("Delete a filter rule")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :id, :number, :desc => N_("rule identifier"), :required => true
    def destroy
      @rule.destroy
      respond_for_show :resource => @rule
    end

    private

    def find_filter
      @filter = ContentViewFilter.find(params[:content_view_filter_id])
    end

    def find_rule
      rule_clazz = ContentViewFilter.rule_class_for(@filter)
      @rule = rule_clazz.where(content_view_filter_id: @filter.id).find(params[:id])
    end

    def rule_params
      unless @rule_params
        if params[:content_view_filter_rule][:errata_ids].is_a?(Hash)
          ids = process_errata_ids(params[:content_view_filter_rule][:errata_ids])
          params[:content_view_filter_rule][:errata_ids] = ids
        end

        if params[:name]
          params[:content_view_filter_rule][:name] = params[:name] = [params[:name]].flatten
        end
      end

      @rule_params ||= params.fetch(:content_view_filter_rule, {}).
            permit(:uuid, :version, :min_version, :max_version, :architecture,
                    :errata_id, :start_date, :end_date, :date_type, :allow_other_types,
                    :types => [], :module_stream_ids => [], :errata_ids => [], name: [])
    end

    def process_errata_ids(select_all_params)
      if select_all_params[:included][:ids].blank?
        select_all_params[:excluded][:ids] ||= [] if select_all_params[:excluded][:ids].nil?
        current_errata_ids = @filter.erratum_rules.map(&:errata_id) + select_all_params[:excluded][:ids]
        query = Erratum
        query = query.where('errata_id not in (?)', current_errata_ids) unless current_errata_ids.empty?
        query.in_repositories(@filter.applicable_repos).pluck(:errata_id)
      else
        []
      end
    end
  end
end
