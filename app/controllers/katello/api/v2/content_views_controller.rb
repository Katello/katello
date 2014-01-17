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
  class Api::V2::ContentViewsController < Api::V2::ApiController
    respond_to :json

    before_filter :find_content_view, :except => [:index, :create]
    before_filter :find_organization, :only => [:index, :create]
    before_filter :authorize

    def rules
      index_rule   = lambda { ContentView.any_readable?(@organization) }
      view_rule    = lambda { @view.readable? }
      create_rule  = lambda { ContentView.creatable?(@organization) }
      edit_rule    = lambda { @view.editable? }
      publish_rule = lambda { @view.publishable? }

      {
        :index        => index_rule,
        :show         => view_rule,
        :create       => create_rule,
        :update       => edit_rule,
        :publish      => publish_rule
      }
    end

    api :GET, "/organizations/:organization_id/content_views", "List content views"
    param :organization_id, :identifier, :desc => "organization identifier"
    param :environment_id, :identifier, :desc => "environment identifier", :required => false
    param :label, String, :desc => "content view label", :required => false
    param :name, String, :desc => "content view name", :required => false
    param :id, :identifier, :desc => "content view id", :required => false
    def index
      options = sort_params

      ids = if @environment
              ContentView.readable(@organization).in_environment(@environment).pluck(:id)
            else
              ContentView.readable(@organization).pluck(:id)
            end
      options[:filters] = [{:terms => {:id => ids}}]

      @search_service.model = ContentView
      respond(:collection => item_search(ContentView, params, options))
    end

    api :POST, "/organizations/:organization_id/content_views", "Create a content view"
    param :organization_id, :identifier, :desc => "Organization identifier"
    param :name, String, :desc => "Name of the content view"
    param :description, String, :desc => "Description of the content view"
    param :label, String, :required => false
    def create
      @view = ContentView.create!(view_params) do |view|
        view.organization = @organization
        view.label ||= labelize_params(params[:content_view])
      end

      respond :resource => @view
    end

    api :PUT, "/content_views/:id", "Update a content view"
    param :id, :number, :desc => "Content view identifier", :required => true
    param :new_name, String, :desc => "New name for the content view"
    param :description, String, :desc => "Updated description for the content view"
    def update
      @view.update_attributes!(view_params)

      respond :resource => @view
    end

    api :POST, "/content_views/:id/publish", "Publish a content view"
    param :id, :identifier, :desc => "Content view identifier", :required => true
    def publish
      @view.publish

      respond_for_show :resource => @view
    end

    api :GET, "/content_views/:id", "Show a content view"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    def show
      respond :resource => @view
    end

    private

    def find_content_view
      @view = ContentView.find(params[:id])
    end

    def view_params
      attrs = [:name, :description]
      attrs.push(:label) if action_name == "create"
      params.require(:content_view).permit(*attrs)
    end
  end
end
