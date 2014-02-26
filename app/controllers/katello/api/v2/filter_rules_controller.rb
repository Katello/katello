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
  class Api::V2::FilterRulesController < Api::V2::ApiController
    respond_to :json

    before_filter :find_filter
    before_filter :find_rule, :except => [:index, :create]
    before_filter :authorize

    def rules
      view_readable = lambda { @filter.content_view.readable? }
      view_editable = lambda { @filter.content_view.editable? }

      {
          :index   => view_readable,
          :create  => view_editable,
          :show    => view_readable,
          :update  => view_editable,
          :destroy => view_editable
      }
    end

    api :GET, "/filters/:filter_id/rules", "List filter rules"
    api :GET, "/rules", "List filter rules"
    param :filter_id, :identifier, :desc => "filter identifier", :required => true
    def index
      options = sort_params
      options[:load_records?] = true
      options[:filters] = [{ :terms => { :id => Filter.rule_ids_for(@filter) } }]

      @search_service.model = Filter.rule_class_for(@filter)
      respond(:collection => item_search(Filter.rule_class_for(@filter), params, options))
    end

    api :POST, "/filters/:filter_id/rules",
        "Create a filter rule. The parameters included should be based upon the filter type."
    api :POST, "/rules",
        "Create a filter rule. The parameters included should be based upon the filter type."
    param :filter_id, :identifier, :desc => "filter identifier", :required => true
    param :name, String, :desc => "package or package group: name"
    param :version, String, :desc => "package: version"
    param :min_version, String, :desc => "package: minimum version"
    param :max_version, String, :desc => "package: maximum version"
    param :errata_id, String, :desc => "erratum: id"
    param :start_date, String, :desc => "erratum: start date (YYYY-MM-DD)"
    param :end_date, String, :desc => "erratum: end date (YYYY-MM-DD)"
    param :types, Array, :desc => "erratum: types (enhancement, bugfix, security)"
    def create
      rule_clazz = Filter.rule_class_for(@filter)
      rule = rule_clazz.create!(rule_params.merge(:filter => @filter))
      respond :resource => rule
    end

    api :GET, "/filters/:filter_id/rules/:id", "Show filter rule info"
    api :GET, "/rules/:id", "Show filter rule info"
    param :filter_id, :identifier, :desc => "filter identifier", :required => true
    param :id, :identifier, :desc => "rule identifier", :required => true
    def show
      respond :resource => @rule
    end

    api :PUT, "/filters/:filter_id/rules/:id",
        "Update a filter rule. The parameters included should be based upon the filter type."
    api :PUT, "/rules/:id",
        "Update a filter rule. The parameters included should be based upon the filter type."
    param :filter_id, :identifier, :desc => "filter identifier", :required => true
    param :id, :identifier, :desc => "rule identifier", :required => true
    param :name, String, :desc => "package or package group: name"
    param :version, String, :desc => "package: version"
    param :min_version, String, :desc => "package: minimum version"
    param :max_version, String, :desc => "package: maximum version"
    param :errata_id, String, :desc => "erratum: id"
    param :start_date, String, :desc => "erratum: start date (YYYY-MM-DD)"
    param :end_date, String, :desc => "erratum: end date (YYYY-MM-DD)"
    param :types, Array, :desc => "erratum: types (enhancement, bugfix, security)"
    def update
      @rule.update_attributes!(rule_params)
      respond :resource => @rule
    end

    api :DELETE, "/filters/:filter_id/rules/:id", "Delete a filter rule"
    api :DELETE, "/rules/:id", "Delete a filter rule"
    param :filter_id, :identifier, :desc => "filter identifier", :required => true
    param :id, :identifier, :desc => "rule identifier", :required => true
    def destroy
      @rule.destroy
      respond :resource => @rule
    end

    private

    def find_filter
      @filter = Filter.find(params[:filter_id])
    end

    def find_rule
      rule_clazz = Filter.rule_class_for(@filter)
      @rule = rule_clazz.find(params[:id])
    end

    def rule_params
      params.require(:filter_rule).permit(:name, :version, :min_version, :max_version,
                                          :errata_id, :start_date, :end_date, :types => [])
    end

  end
end
