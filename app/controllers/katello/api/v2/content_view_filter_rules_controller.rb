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
  class Api::V2::ContentViewFilterRulesController < Api::V2::ApiController
    before_filter :find_filter
    before_filter :find_rule, :except => [:index, :create]

    api :GET, "/content_view_filters/:content_view_filter_id/rules", N_("List filter rules")
    param :content_view_filter_id, :identifier, :desc => N_("filter identifier"), :required => true
    def index
      options = sort_params
      options[:load_records?] = true
      options[:filters] = [{ :terms => { :id => ContentViewFilter.rule_ids_for(@filter) } }]

      @search_service.model = ContentViewFilter.rule_class_for(@filter)
      respond(:collection => item_search(ContentViewFilter.rule_class_for(@filter), params, options))
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

      params.fetch(:content_view_filter_rule, {})
            .permit(:uuid, :name, :version, :min_version, :max_version,
                    :errata_id, :start_date, :end_date,
                    :types => [], :errata_ids => [])
    end

    def process_errata_ids(select_all_params)
      if select_all_params[:included][:ids].blank?
        load_search_service
        step_size = 50

        current_errata_ids = @filter.erratum_rules.map(&:errata_id)
        current_errata_ids += select_all_params[:excluded][:ids]
        repo_ids = @filter.applicable_repos.pluck(:pulp_id)
        select_all_params[:included][:params][:repo_ids] = repo_ids

        search_filters = [
          { :not => { :terms => { :errata_id_exact => current_errata_ids }}}
        ]
        search_filters.concat(Errata.filters(select_all_params[:included][:params]))

        options = sort_params
        options[:filters] = search_filters
        options[:fields] = [:errata_id]

        options[:per_page] = 1
        collection = item_search(Errata, select_all_params, options)
        total = collection[:subtotal]
        results = []

        (0..total).step(step_size).flat_map do |start|
          options[:per_page] = step_size
          options[:page] = start / step_size
          results.concat(item_search(Errata, select_all_params, options)[:results])
        end

        results.collect { |erratum| erratum.errata_id }
      else
        []
      end
    end
  end
end
