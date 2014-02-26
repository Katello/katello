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
    before_filter :find_environment, :only => [:index]
    before_filter :load_search_service, :only => [:index, :available_puppet_modules]

    before_filter :authorize

    wrap_parameters :include => (ContentView.attribute_names + %w(repository_ids component_ids))

    def rules
      index_rule   = lambda { ContentView.any_readable?(@organization) }
      view_rule    = lambda { @view.readable? }
      create_rule  = lambda { ContentView.creatable?(@organization) }
      edit_rule    = lambda { @view.editable? }
      publish_rule = lambda { @view.publishable? }

      {
        :index                    => index_rule,
        :show                     => view_rule,
        :create                   => create_rule,
        :update                   => edit_rule,
        :publish                  => publish_rule,
        :available_puppet_modules => view_rule,
        :history                  => view_rule
      }
    end

    api :GET, "/organizations/:organization_id/content_views", "List content views"
    api :GET, "/content_views", "List content views"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :environment_id, :identifier, :desc => "environment identifier"
    def index
      options = sort_params
      options[:load_records?] = true

      ids = if @environment
              # TODO: move environment to an ES filter
              ContentView.non_default.readable(@organization).in_environment(@environment).pluck(:id)
            else
              ContentView.non_default.readable(@organization).pluck(:id)
            end
      options[:filters] = [{:terms => {:id => ids}}]

      @search_service.model = ContentView
      respond(:collection => item_search(ContentView, params, options))
    end

    api :POST, "/organizations/:organization_id/content_views", "Create a content view"
    api :POST, "/content_views", "Create a content view"
    param :organization_id, :identifier, :desc => "Organization identifier", :required => true
    param :name, String, :desc => "Name of the content view", :required => true
    param :description, String, :desc => "Description of the content view"
    param :label, String, :desc => "Content view label"
    param :repositoriy_ids, Array, :desc => "List of repository ids"
    param :composite, :bool, :desc => "Composite content view"
    def create
      @view = ContentView.create!(view_params) do |view|
        view.organization = @organization
        view.label ||= labelize_params(params[:content_view])
      end

      respond :resource => @view
    end

    api :PUT, "/content_views/:id", "Update a content view"
    param :id, :number, :desc => "Content view identifier", :required => true
    param :name, String, :desc => "New name for the content view"
    param :description, String, :desc => "Updated description for the content view"
    param :repository_ids, Array, :desc => "List of repository ids"
    param :component_ids, Array, :desc => "List of component content view version ids"
    def update
      @view.update_attributes!(view_params)

      respond :resource => @view
    end

    api :POST, "/content_views/:id/publish", "Publish a content view"
    param :id, :identifier, :desc => "Content view identifier", :required => true
    def publish
      @view.publish(:async => false)

      respond_for_show :resource => @view
    end

    api :GET, "/content_views/:id", "Show a content view"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    def show
      respond :resource => @view
    end

    api :GET, "/content_views/:id/available_puppet_modules",
        "Get puppet modules that are available to be added to the content view"
    param :id, :identifier, :desc => "content view numeric identifier", :required => true
    def available_puppet_modules
      current_ids = @view.content_view_puppet_modules.map(&:uuid)
      repo_ids = @view.organization.library.puppet_repositories.pluck(:pulp_id)
      search_filters = [{ :terms => { :repoids => repo_ids } },
                        { :not => { :terms => { :id => current_ids } } }]
      options = { :filters => search_filters }

      respond_for_index :template => '../puppet_modules/index',
                        :collection => item_search(PuppetModule, params, options)
    end

    api :GET, "/content_views/:id/history", "Show a content view's history"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    def history
      respond_for_index(:collection => @view.history)
    end

    private

    def find_content_view
      @view = ContentView.non_default.find(params[:id])
    end

    def view_params
      attrs = [:name, :description, {:repository_ids => []}, {:component_ids => []}]
      attrs.push(:label, :composite) if action_name == "create"
      params.require(:content_view).permit(*attrs)
    end

    def find_environment
      return unless params.key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
    end
  end
end
