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
  class Api::V2::ContentViewPuppetModulesController < Api::V2::ApiController
    before_filter :find_content_view
    before_filter :authorize
    before_filter :find_puppet_module, :only => [:show, :update, :destroy]

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

    api :GET, "/content_views/:content_view_id/puppet_modules", "List content view puppet modules"
    param :content_view_id, :identifier, :desc => "content view identifier", :required => true
    def index
      options = sort_params
      options[:load_records?] = true
      options[:filters] = [{ :terms => { :id => @view.content_view_puppet_module_ids } }]

      @search_service.model = ContentViewPuppetModule
      respond(:collection => item_search(ContentViewPuppetModule, params, options))
    end

    api :POST, "/content_views/:content_view_id/puppet_modules",
        "Add a puppet module to the content view"
    param :content_view_id, :identifier, :desc => "content view identifier", :required => true
    param :name, String, :desc => "name of the puppet module"
    param :author, String, :desc => "author of the puppet module"
    param :uuid, String, :desc => "the uuid of the puppet module to associate"
    def create
      @puppet_module = ContentViewPuppetModule.create!(puppet_module_params) do |puppet_module|
        puppet_module.content_view = @view
      end

      respond :resource => @puppet_module
    end

    api :GET, "/content_views/:content_view_id/puppet_modules/:id", "Show a content view puppet module"
    param :content_view_id, :number, :desc => "content view numeric identifier", :required => true
    def show
      respond :resource => @puppet_module
    end

    api :PUT, "/content_views/:content_view_id/puppet_modules/:id",
        "Update a puppet module associated with the content view"
    param :content_view_id, :identifier, :desc => "content view identifier", :required => true
    param :id, :identifier, :desc => "puppet module identifier", :required => true
    param :name, String, :desc => "name of the puppet module"
    param :author, String, :desc => "author of the puppet module"
    param :uuid, String, :desc => "the uuid of the puppet module to associate"
    def update
      @puppet_module.update_attributes!(puppet_module_params)
      respond :resource => @puppet_module
    end

    api :DELETE, "/content_views/:content_view_id/puppet_modules/:id",
        "Remove a puppet module from the content view"
    param :content_view_id, :identifier, :desc => "content view identifier", :required => true
    param :id, :identifier, :desc => "puppet module identifierr", :required => true
    def destroy
      @puppet_module.destroy
      respond :resource => @puppet_module
    end

    private

    def find_content_view
      @view = ContentView.non_default.find(params[:content_view_id])
    end

    def find_puppet_module
      @puppet_module = ContentViewPuppetModule.find(params[:id])
    end

    def puppet_module_params
      attrs = [:name, :author, :uuid]
      params.require(:content_view_puppet_module).permit(*attrs)
    end
  end
end
