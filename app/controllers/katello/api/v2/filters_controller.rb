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
class Api::V2::FiltersController < Api::V2::ApiController
  respond_to :json

  before_filter :find_content_view
  before_filter :find_filter, :except => [:index, :create]
  before_filter :authorize

  wrap_parameters :include => (Filter.attribute_names + %w(repository_ids))

  def rules
    view_readable = lambda { @view.readable? }
    view_editable = lambda { @view.editable? }

    {
        :index   => view_readable,
        :create  => view_editable,
        :show    => view_readable,
        :update  => view_editable,
        :destroy => view_editable
    }
  end

  api :GET, "/content_views/:content_view_id/filters", "List filters"
  param :content_view_id, :number, :desc => "content view identifier", :required => true
  def index
    options = sort_params
    options[:load_records?] = true
    options[:filters] = [{ :terms => { :id => @view.filter_ids } }]

    @search_service.model = Filter
    respond(:collection => item_search(Filter, params, options))
  end

  api :POST, "/content_views/:content_view_id/filters",
      "Create a filter for a content view"
  param :content_view_id, :number, :desc => "content view identifier", :required => true
  param :filter, Hash, :required => true, :action_aware => true do
    param :name, String, :desc => "name of the filter", :required => true
    param :type, String, :desc => "type of filter (e.g. rpm, package_group, erratum, puppet_module)", :required => true
    param :parameters, Hash, :desc => "the filter parameter rules"
  end
  def create
    filter = Filter.create_for(params[:type], filter_params.merge(:content_view => @view))
    respond :resource => filter
  end

  api :GET, "/content_views/:content_view_id/filters/:id", "Show filter info"
  param :content_view_id, :number, :desc => "content view identifier", :required => true
  param :id, :number, :desc => "filter identifier", :required => true
  def show
    respond :resource => @filter
  end

  api :PUT, "/content_views/:content_view_id/filters/:id", "Update a filter"
  param :content_view_id, :number, :desc => "Content view identifier", :required => true
  param :id, :number, :desc => "id of the filter", :required => true
  param :name, String, :desc => "New name for the filter"
  param :repository_ids, Array, :desc => "List of repository ids"
  def update
    @filter.update_attributes!(filter_params)
    respond :resource => @filter
  end

  api :DELETE, "/content_views/:content_view_id/filters/:id", "Delete a filter"
  param :content_view_id, :number, :desc => "content view identifier", :required => true
  param :id, :number, :desc => "filter identifier", :required => true
  def destroy
    @filter.destroy
    respond :resource => @filter
  end

  private

  def find_content_view
    @view = ContentView.find(params[:content_view_id])
  end

  def find_filter
    id = params[:id] || params[:filter_id]
    @filter = Filter.where(:content_view_id => @view).find(id)
  end

  def filter_params
    filter_parameters = params.require(:filter).permit(:name, :repository_ids => [])

    # the :parameters will be vaildated by the model layer (e.g. PackageFilter)
    filter_parameters[:parameters] = params[:filter][:parameters].with_indifferent_access
    filter_parameters
  end

end
end
