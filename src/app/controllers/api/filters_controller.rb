#
# Katello Organization actions
# Copyright (c) 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

class Api::FiltersController < Api::ApiController
  respond_to :json
  before_filter :find_organization
  before_filter :find_definition
  before_filter :find_filter, :except => [:index, :create]
  before_filter :authorize

  def rules
    definition_readable = lambda { @definition && @definition.readable? }
    definition_editable = lambda { @definition && @definition.editable? }

    {
      :index => definition_readable,
      :create => definition_editable,
      :show => definition_readable,
      :destroy => definition_editable,
    }
  end

  api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters",
    "List filters"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "label of the content view definition", :required => true
  def index
    query_params.delete(:organization_id)
    render :json => @definition.filters
  end

  api :POST, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters",
    "Create a filter for a content view definition"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "label of the content view definition", :required => true
  param :filter, String, :desc => "name of the filter", :required => true
  def create
    filter = Filter.create!(:content_view_definition => @definition, :name => params[:filter])
    render :json => filter
  end


  api :GET,  "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id",
      "Show filter info"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "label of the content view definition", :required => true
  param :id, :String, :desc => "name of the filter", :required => true
  def show
    render :json => @filter
  end

  api :DELETE, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id",
   "Delete a filter"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "label of the content view definition", :required => true
  param :id, :String, :desc => "name of the filter", :required => true
  def destroy
    @filter.destroy
    render :json => @filter
  end

  private

  def find_definition
    @definition = ContentViewDefinition.where(:label => params[:content_view_definition_id], :organization_id => @organization).first
    raise HttpErrors::NotFound, _("Couldn't find content definition '%s'") % params[:content_view_definition_id] if @definition.nil?
    @definition
  end

  def find_filter
    @filter = Filter.where(:name => params[:id], :content_view_definition_id => @definition).first
    raise HttpErrors::NotFound, _("Couldn't find filter '%s'") % params[:id] if @filter.nil?
    @filter
  end
end
