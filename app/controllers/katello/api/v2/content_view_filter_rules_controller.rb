module Katello
  class Api::V2::ContentViewFilterRulesController < Api::V2::ApiController
    before_filter :find_filter
    before_filter :find_rule, :except => [:index, :create]

    api :GET, "/content_view_filters/:content_view_filter_id/rules", N_("List filter rules")
    param :content_view_filter_id, :identifier, :desc => N_("filter identifier"), :required => true
    def index
      ids = ContentViewFilter.rule_ids_for(@filter)
      results = ids.map { |id| ContentViewFilter.rule_class_for(@filter).find(id) }
      collection = {
        :results  => results.uniq,
        :subtotal => results.count,
        :total    => results.count
      }
      respond :collection => collection
    end

    api :POST, "/content_view_filters/:content_view_filter_id/rules",
        N_("Create a filter rule. The parameters included should be based upon the filter type.")
    param :content_view_filter_id, :identifier, :desc => N_("filter identifier"), :required => true
    param :name, String, :desc => N_("package or package group: name")
    param :version, String, :desc => N_("package: version")
    param :min_version, String, :desc => N_("package: minimum version")
    param :max_version, String, :desc => N_("package: maximum version")
    param :errata_id, String, :desc => N_("erratum: id")
    param :errata_ids, Array, :desc => N_("erratum: IDs or a select all object")
    param :start_date, String, :desc => N_("erratum: start date (YYYY-MM-DD)")
    param :end_date, String, :desc => N_("erratum: end date (YYYY-MM-DD)")
    param :types, Array, :desc => N_("erratum: types (enhancement, bugfix, security)")
    param :date_type, String, :desc => N_("erratum: search using the 'Issued On' or 'Updated On' column of the errata. Values are 'issued'/'updated'")
    def create
      rule_clazz = ContentViewFilter.rule_class_for(@filter)

      if rule_params.key?(:errata_ids)
        rules = []
        rule_params[:errata_ids].each do |errata_id|
          rules << rule_clazz.create!({:errata_id => errata_id}.merge(:filter => @filter))
        end
      else
        rule = rule_clazz.create!(rule_params.merge(:filter => @filter))
      end

      if rules && rule.nil?
        respond_for_index(:collection => {:results => rules}, :template => 'index')
      else
        respond :resource => rule
      end
    end

    api :GET, "/content_view_filters/:content_view_filter_id/rules/:id", N_("Show filter rule info")
    param :content_view_filter_id, :identifier, :desc => N_("filter identifier"), :required => true
    param :id, :identifier, :desc => N_("rule identifier"), :required => true
    def show
      respond :resource => @rule
    end

    api :PUT, "/content_view_filters/:content_view_filter_id/rules/:id",
        N_("Update a filter rule. The parameters included should be based upon the filter type.")
    param :content_view_filter_id, :identifier, :desc => N_("filter identifier"), :required => true
    param :id, :identifier, :desc => N_("rule identifier"), :required => true
    param :name, String, :desc => N_("package or package group: name")
    param :version, String, :desc => N_("package: version")
    param :min_version, String, :desc => N_("package: minimum version")
    param :max_version, String, :desc => N_("package: maximum version")
    param :errata_id, String, :desc => N_("erratum: id")
    param :start_date, String, :desc => N_("erratum: start date (YYYY-MM-DD)")
    param :end_date, String, :desc => N_("erratum: end date (YYYY-MM-DD)")
    param :types, Array, :desc => N_("erratum: types (enhancement, bugfix, security)")
    def update
      update_params = rule_params

      if @rule.filter.content_type == 'package'
        update_params[:version] = "" unless rule_params[:version]
        update_params[:min_version] = "" unless rule_params[:min_version]
        update_params[:max_version] = "" unless rule_params[:max_version]
      end

      @rule.update_attributes!(update_params)
      respond :resource => @rule
    end

    api :DELETE, "/content_view_filters/:content_view_filter_id/rules/:id", N_("Delete a filter rule")
    param :content_view_filter_id, :identifier, :desc => N_("filter identifier"), :required => true
    param :id, :identifier, :desc => N_("rule identifier"), :required => true
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
      @rule = rule_clazz.find(params[:id])
    end

    def rule_params
      if params[:content_view_filter_rule][:errata_ids].is_a?(Hash)
        ids = process_errata_ids(params[:content_view_filter_rule][:errata_ids])
        params[:content_view_filter_rule][:errata_ids] = ids
      end

      params.fetch(:content_view_filter_rule, {}).
            permit(:uuid, :name, :version, :min_version, :max_version,
                    :errata_id, :start_date, :end_date, :date_type,
                    :types => [], :errata_ids => [])
    end

    def process_errata_ids(select_all_params)
      if select_all_params[:included][:ids].blank?
        current_errata_ids = @filter.erratum_rules.map(&:errata_id) + select_all_params[:excluded][:ids]
        Erratum.where('errata_id not in (?)', current_errata_ids).in_repositories(@filter.applicable_repos).pluck(:errata_id)
      else
        []
      end
    end
  end
end
