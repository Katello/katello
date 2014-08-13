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

require 'strong_parameters'

module Katello
  class Api::V2::ApiController < Api::ApiController

    include Api::Version2
    include Api::V2::Rendering
    include Api::V2::ErrorHandling

    # support for session (thread-local) variables must be the last filter in this class
    include Foreman::ThreadSession::Cleaner

    before_filter :load_search_service, :only => [:index]
    before_filter :turn_on_strong_params

    resource_description do
      api_version 'v2'
      api_base_url "#{Katello.config.url_prefix}/api"
    end

    def_param_group :search do
      param :search, String, :desc => N_("Search string")
      param :page, :number, :desc => N_("Page number, starting at 1")
      param :per_page,  :number, :desc => N_("Number of results per page to return")
      param :order, String, :desc => N_("Sort field and order, eg. 'name DESC'")
      param :full_results, :bool, :desc => N_("Whether or not to show all results")
      param :sort, Hash, :desc => N_("Hash version of 'order' param") do
        param :by, String, :desc => N_("Field to sort the results on")
        param :order, String, :desc => N_("How to order the sorted results (e.g. ASC for ascending)")
      end
    end

    param :object_root, String, :desc => N_("root-node of single-resource responses (optional)")
    param :root_name, String, :desc => N_("root-node of collection contained in responses (default: 'results')")

    def item_search(item_class, params, options)
      fail "@search_service search not defined" if @search_service.nil?
      if params[:order]
        (params[:sort_by], params[:sort_order]) = params[:order].split(' ')
      end
      options[:sort_by] = params[:sort_by] if params[:sort_by]
      options[:sort_order] = params[:sort_order] if params[:sort_order]
      options[:full_result] = params[:full_result] if params[:full_result]

      unless options[:full_result]
        options[:per_page] = params[:per_page] || ::Setting::General.entries_per_page
        options[:page] = params[:page] || 1
        offset = (options[:page].to_i - 1) * options[:per_page].to_i
      end

      @search_service.model = item_class

      if block_given?
        options[:offset] = offset
        @search_service.search_options = options
        @search_service.query_string = params[:search]
        results, total_count = yield(@search_service)
      else
        results, total_count = @search_service.retrieve(params[:search], offset, options)
      end
      {
        :results  => results,
        :subtotal => total_count,
        :total    => @search_service.total_items,
        :page     => options[:page],
        :per_page => options[:per_page]
      }
    end

    def facet_search(item_class, term , options)
      fail "@search_service search not defined" if @search_service.nil?
      facet_name = 'facet_search'

      @search_service.model =  item_class
      options[:per_page] = 1
      options[:facets] = {facet_name => term}
      options[:facet_filters] =  {:and => options[:filters]}

      @search_service.retrieve('', 0, options)

      facets = @search_service.facets[facet_name]['terms']
      results = facets.collect{|f| Katello::Glue::ElasticSearch::FacetItem.new(f)}
      {
        :results  => results.sort_by{|f| f.term },
        :subtotal => results.length,
        :total    => results.length,
      }
    end

    def get_class(model_name)
      "Katello::#{model_name.classify}".constantize
    rescue NameError
      super(model_name)
    end

    protected

    def is_database_id?(num)
      Integer(num)
      true
    rescue
      false
    end

    def labelize_params(params)
      return params[:label] unless params.try(:[], :label).nil?
      return Util::Model.labelize(params[:name]) unless params.try(:[], :name).nil?
    end

    def find_organization
      @organization = Organization.current || find_optional_organization
      fail HttpErrors::NotFound, _("One of parameters [ %s ] required but not specified.") %
          organization_id_keys.join(", ") if @organization.nil?
      @organization
    end

    def sort_params
      options = {}
      options[:sort_by] = params[:sort_by] if params[:sort_by]
      options[:sort_order] = params[:sort_order] if params[:sort_order]
      options
    end

    def find_optional_organization
      org_id = organization_id
      return if org_id.nil?

      @organization = get_organization(org_id)
      fail HttpErrors::NotFound, _("Couldn't find organization '%s'") % org_id if @organization.nil?
      @organization
    end

    def organization_id
      key = organization_id_keys.find { |k| !params[k].nil? }
      return params[key]
    end

    def organization_id_keys
      return [:organization_id]
    end

    def get_organization(org_id)
      return Organization.find_by_id(org_id)
    end

    def find_default_organization_and_or_environment
      return if (params.keys & %w{organization_id owner environment_id host_collection_id}).any?

      if current_user.default_organization.present?
        @organization = current_user.default_organization
        @environment = @organization.library
      else
        fail HttpErrors::NotFound, _("You have not set a default organization on the user %s.") % current_user.login
      end
    end

    def param_rules
      # we're using strong params in v2
      {}
    end

    def turn_on_strong_params
      # prevent create and update_attributes from being called without strong params
      Thread.current[:strong_parameters] = true
    end

  end
end
