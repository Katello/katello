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
  class Api::V2::ContentViewsController < Api::V2::ApiController
    before_filter :find_content_view, :except => [:index, :create]
    before_filter :find_organization, :only => [:index, :create]
    before_filter :find_environment, :only => [:index, :remove_from_environment]
    before_filter :load_search_service, :only => [:index, :history, :available_puppet_modules,
                                                  :available_puppet_module_names]
    before_filter :authorize

    wrap_parameters :include => (ContentView.attribute_names + %w(repository_ids component_ids))

    resource_description do
      api_version "v2"
    end

    def_param_group :content_view do
      param :description, String, :desc => "Description for the content view"
      param :repository_ids, Array, :desc => "List of repository ids"
      param :component_ids, Array, :desc => "List of component content view version ids for composite views"
    end

    def rules
      index_rule   = lambda { ContentView.any_readable?(@organization) }
      view_rule    = lambda { @view.readable? }
      create_rule  = lambda { ContentView.creatable?(@organization) }
      edit_rule    = lambda { @view.editable? }
      publish_rule = lambda { @view.publishable? }
      promote_rule = lambda {@environment.changesets_promotable? && @view.promotable?}

      {
        :index                         => index_rule,
        :show                          => view_rule,
        :create                        => create_rule,
        :update                        => edit_rule,
        :publish                       => publish_rule,
        :available_puppet_modules      => view_rule,
        :history                       => view_rule,
        :available_puppet_module_names => view_rule,
        :remove_from_environment       => promote_rule,
        :remove                        => edit_rule,
        :destroy                       => edit_rule
      }
    end

    api :GET, "/organizations/:organization_id/content_views", "List content views"
    api :GET, "/content_views", "List content views"
    param :organization_id, :number, :desc => "organization identifier", :required => true
    param :environment_id, :identifier, :desc => "environment identifier"
    param :nondefault, :bool, :desc => "Filter out default content views"
    def index
      options = sort_params
      options[:load_records?] = true

      ids = if @environment
              # TODO: move environment to an ES filter
              ContentView.readable(@organization).in_environment(@environment).pluck("#{ContentView.table_name}.id")
            else
              ContentView.readable(@organization).pluck(:id)
            end
      options[:filters] = [{:terms => {:id => ids}}]

      options[:filters] << {:term => {:default => false}} if params[:nondefault]

      respond(:collection => item_search(ContentView, params, options))
    end

    api :POST, "/organizations/:organization_id/content_views", "Create a content view"
    api :POST, "/content_views", "Create a content view"
    param :organization_id, :number, :desc => "Organization identifier", :required => true
    param :name, String, :desc => "Name of the content view", :required => true
    param :label, String, :desc => "Content view label"
    param :composite, :bool, :desc => "Composite content view"
    param_group :content_view
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
    param_group :content_view
    def update
      @view.update_attributes!(view_params)

      respond :resource => @view
    end

    api :POST, "/content_views/:id/publish", "Publish a content view"
    param :id, :identifier, :desc => "Content view identifier", :required => true
    def publish
      task = async_task(::Actions::Katello::ContentView::Publish, @view)
      respond_for_async :resource => task
    end

    api :GET, "/content_views/:id", "Show a content view"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    def show
      respond :resource => @view
    end

    api :GET, "/content_views/:id/available_puppet_modules",
        "Get puppet modules that are available to be added to the content view"
    param :id, :identifier, :desc => "content view numeric identifier", :required => true
    param :name, String, :desc => "module name to restrict modules for", :required => false
    def available_puppet_modules
      current_ids = @view.content_view_puppet_modules.map(&:uuid).reject{|p| p.nil?}

      repo_ids = @view.organization.library.puppet_repositories.readable(@view.organization.library).pluck(:pulp_id)
      search_filters = [{ :terms => { :repoids => repo_ids }}]

      if !current_ids.empty?
        search_filters << { :not => { :terms => { :id => current_ids } } }
      end
      search_filters << { :term => { :name => params[:name] } } if params[:name]
      options = { :filters => search_filters }

      collection = item_search(PuppetModule, params, options)
      collection[:results] = collection[:results].map{|i| PuppetModule.new(i.as_json) }

      respond_for_index :template => 'puppet_modules', :collection => collection
    end

    api :GET, "/content_views/:id/available_puppet_module_names",
        "Get puppet modules names that are available to be added to the content view"
    param :id, :identifier, :desc => "content view numeric identifier", :required => true
    def available_puppet_module_names
      current_names = @view.content_view_puppet_modules.map(&:name).reject{|p| p.nil?}
      repo_ids = @view.organization.library.puppet_repositories.readable(
          @view.organization.library).pluck(:pulp_id)
      search_filters = [{ :terms => { :repoids => repo_ids } }]

      if !current_names.empty?
        search_filters << { :not => { :terms => { :name => current_names } } }
      end

      options = {:filters  => search_filters}

      respond_for_index :template => '../puppet_modules/names',
                        :collection => facet_search(PuppetModule, 'name', options)
    end

    api :GET, "/content_views/:id/history", "Show a content view's history"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    def history
      options = sort_params
      options[:load_records?] = true
      options[:filters] = [{:term => {:content_view_id => @view.id}}]

      respond_for_index :template => '../content_view_histories/index',
                        :collection => item_search(ContentViewHistory, params, options)
    end

    api :DELETE, "/content_views/:id/environments/:environment_id", "Remove a content view from an environment"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    param :environment_id, :number, :desc => "environment numeric identifier", :required => true
    def remove_from_environment
      task = async_task(::Actions::Katello::ContentView::RemoveFromEnvironment, @view, @environment)
      respond_for_async :resource => task
    end

    api :PUT, "/content_views/:id/remove", "Remove versions and/or environments from a content view and reassign systems and keys"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    param :environment_ids, :number, :desc => "environment numeric identifiers to be removed"
    param :content_view_version_ids, :number, :desc => "content view version identifiers to be deleted"
    param :system_content_view_id, :number, :desc => "content view to reassign orphaned systems to"
    param :system_environment_id, :number, :desc => "environment to reassign orphaned systems to"
    param :key_content_view_id, :number, :desc => "content view to reassign orphaned activation keys to"
    param :key_environment_id, :number, :desc => "environment to reassign orphaned activation keys to"
    def remove
      cv_envs = ContentViewEnvironment.where(:environment_id => params[:environment_ids],
                                             :content_view_id => params[:id]
                                            )
      versions = @view.versions.where(:id => params[:content_view_version_ids])

      if cv_envs.empty? && versions.empty?
        fail _("There either were no environments nor versions specified or there were invalid environments/versions specified. "\
               "Please check environment_ids and content_view_version_ids parameters.")
      end

      options = params.slice(:system_content_view_id,
                             :system_environment_id,
                             :key_content_view_id,
                             :key_environment_id
                            ).reject { |k, v| v.nil? }
      options[:content_view_versions] = versions
      options[:content_view_environments] = cv_envs

      task = async_task(::Actions::Katello::ContentView::Remove, @view, options)
      respond_for_async :resource => task
    end

    api :DELETE, "/content_views/:id", "Delete a content view"
    param :id, :number, :desc => "content view numeric identifier", :required => true
    def destroy
      task = async_task(::Actions::Katello::ContentView::Destroy, @view)
      respond_for_async :resource => task
    end

    private

    def find_content_view
      @view = ContentView.find(params[:id])

      if @view.default? && !%w(show history).include?(params[:action])
        fail HttpErrors::BadRequest.new(_("The default content view cannot be edited, published, or deleted."))
      end
    end

    def view_params
      attrs = [:name, :description, {:repository_ids => []}, {:component_ids => []}]
      attrs.push(:label, :composite) if action_name == "create"
      params.require(:content_view).permit(*attrs)
    end

    def find_environment
      return if !params.key?(:environment_id) && params[:action] == "index"
      @environment = KTEnvironment.find(params[:environment_id])
    end
  end
end
