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

class Api::V2::ApiController < Api::ApiController

  include Api::Version2
  include Api::V2::Rendering
  include Api::V2::ErrorHandling

  # support for session (thread-local) variables must be the last filter in this class
  include Util::ThreadSession::Controller
  include AuthorizationRules

  before_filter :load_search_service, :only => [:index]

  resource_description do
    api_version 'v2'
  end

  def_param_group :search do
    param :search, String, :desc => "Search string"
    param :offset, :number, :desc => "Starting location to retrieve data from"
    param :limit,  :number, :desc => "Number of results to return"
    param :sort, Hash do
      param :by, String, :desc => "Field to sort the results on"
      param :order, String, :desc => "How to order the sorted results (e.g. ASC for ascending)"
    end
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

end
