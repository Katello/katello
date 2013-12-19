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
  class Api::V2::ApiController < Api::ApiController

    include Api::Version2
    include Api::V2::Rendering
    include Api::V2::ErrorHandling

    # support for session (thread-local) variables must be the last filter in this class
    include Foreman::ThreadSession::Cleaner
    include AuthorizationRules

    before_filter :load_search_service, :only => [:index]

    resource_description do
      api_version 'v2'
    end

    def_param_group :search do
      param :search, String, :desc => "Search string"
      param :page, :number, :desc => "Page number, starting at 1"
      param :per_page,  :number, :desc => "Number of results per page to return"
      param :order, String, :desc => "Sort field and order, eg. 'name DESC'"
      param :sort, Hash, :desc => "Hash version of 'order' param" do
        param :by, String, :desc => "Field to sort the results on"
        param :order, String, :desc => "How to order the sorted results (e.g. ASC for ascending)"
      end
    end

    param :object_root, String, :desc => "root-node of single-resource responses (optional)"
    param :root_name, String, :desc => "root-node of collection contained in responses (default: 'results')"

    def item_search(item_class, params, options)
      if params[:order]
        (params[:sort_by], params[:sort_order]) = params[:order].split(' ')
      end
      options[:sort_by] = params[:sort_by] if params[:sort_by]
      options[:sort_order] = params[:sort_order] if params[:sort_order]
      options[:per_page] = params[:per_page] || ::Setting::General.entries_per_page  unless options[:full_result]
      options[:page] = params[:page] || 1
      offset = (options[:page].to_i - 1) * options[:per_page].to_i

      @search_service.model = item_class
      results, total_count = @search_service.retrieve(params[:search], offset, options)

      {
        :results  => results,
        :subtotal => total_count,
        :total    => @search_service.total_items,
        :page     => options[:page],
        :per_page => options[:per_page]
      }
    end

    protected

    def labelize_params(params)
      return params[:label] unless params.try(:[], :label).nil?
      return Util::Model.labelize(params[:name]) unless params.try(:[], :name).nil?
    end

    def find_organization
      organization_id = params[:organization_id]
      @organization = Organization.without_deleting.having_name_or_label(organization_id).first
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
      # name/label is always unique
      return Organization.without_deleting.having_name_or_label(org_id).first
    end

    def find_default_organization_and_or_environment
      return if (params.keys & %w{organization_id owner environment_id system_group_id}).any?

      @environment = current_user.default_environment
      if @environment
        @organization = @environment.organization
      else
        fail HttpErrors::NotFound, _("You have not set a default organization and environment on the user %s.") % current_user.login
      end
    end

  end
end
