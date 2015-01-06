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
    include Concerns::Authorization::Api::V2::ContentViewsController
    before_filter :find_content_view, :except => [:index, :create]
    before_filter :find_organization, :only => [:create]
    before_filter :find_optional_organization, :only => [:index]
    before_filter :load_search_service, :only => [:index, :history, :available_puppet_modules,
                                                  :available_puppet_module_names]
    before_filter :find_environment, :only => [:index, :remove_from_environment]

    wrap_parameters :include => (ContentView.attribute_names + %w(repository_ids component_ids))

    resource_description do
      api_version "v2"
    end

    def_param_group :content_view do
      param :description, String, :desc => N_("Description for the content view")
      param :repository_ids, Array, :desc => N_("List of repository ids")
      param :component_ids, Array, :desc => N_("List of component content view version ids for composite views")
    end

    api :GET, "/organizations/:organization_id/content_views", N_("List content views")
    api :GET, "/content_views", N_("List content views")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :environment_id, :identifier, :desc => N_("environment identifier")
    param :nondefault, :bool, :desc => N_("Filter out default content views")
    param :noncomposite, :bool, :desc => N_("Filter out composite content views")
    param :without, Array, :desc => N_("Do not include this array of content views")
    param :name, String, :desc => N_("Name of the content view"), :required => false
    def index
      options = sort_params
      options[:load_records?] = true

      readable_cvs = ContentView.readable
      readable_cvs = readable_cvs.where(:organization_id => @organization.id) if @organization
      readable_cvs = readable_cvs.in_environment(@environment) if @environment
      ids = readable_cvs.pluck("#{Katello::ContentView.table_name}.id")

      options[:filters] = [{:terms => {:id => ids}}]
      options[:filters] << {:not => {:terms => {:id => params[:without]}}} if params[:without]

      options[:filters] << {:term => {:default => false}} if params[:nondefault]
      options[:filters] << {:term => {:composite => false}} if params[:noncomposite]
      options[:filters] << {:term => {:name => params[:name]}} if params[:name]

      respond(:collection => item_search(ContentView, params, options))
    end

    api :POST, "/organizations/:organization_id/content_views", N_("Create a content view")
    api :POST, "/content_views", N_("Create a content view")
    param :organization_id, :number, :desc => N_("Organization identifier"), :required => true
    param :name, String, :desc => N_("Name of the content view"), :required => true
    param :label, String, :desc => N_("Content view label")
    param :composite, :bool, :desc => N_("Composite content view")
    param_group :content_view
    def create
      @view = ContentView.create!(view_params) do |view|
        view.organization = @organization
        view.label ||= labelize_params(params[:content_view])
      end

      respond :resource => @view
    end

    api :PUT, "/content_views/:id", N_("Update a content view")
    param :id, :number, :desc => N_("Content view identifier"), :required => true
    param :name, String, :desc => N_("New name for the content view")
    param_group :content_view
    def update
      @view.update_attributes!(view_params)

      respond :resource => @view
    end

    api :POST, "/content_views/:id/publish", N_("Publish a content view")
    param :id, :identifier, :desc => N_("Content view identifier"), :required => true
    param :description, String, :desc => N_("Description for the new published content view version")
    def publish
      task = async_task(::Actions::Katello::ContentView::Publish, @view, params[:description])
      respond_for_async :resource => task
    end

    api :GET, "/content_views/:id", N_("Show a content view")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    def show
      respond :resource => @view
    end

    api :GET, "/content_views/:id/available_puppet_modules",
        N_("Get puppet modules that are available to be added to the content view")
    param :id, :identifier, :desc => N_("content view numeric identifier"), :required => true
    param :name, String, :desc => N_("module name to restrict modules for"), :required => false
    def available_puppet_modules
      current_ids = @view.content_view_puppet_modules.map(&:uuid).reject { |p| p.nil? }

      repo_ids = @view.organization.library.puppet_repositories.pluck(:pulp_id)
      search_filters = [{ :terms => { :repoids => repo_ids }}]

      unless current_ids.empty?
        search_filters << { :not => { :terms => { :id => current_ids } } }
      end
      search_filters << { :term => { :name => params[:name] } } if params[:name]
      options = { :filters => search_filters, :sort_by => 'sortable_version', :sort_order => 'DESC' }

      collection = item_search(PuppetModule, params, options)
      collection[:results] = collection[:results].map { |i| PuppetModule.new(i.as_json) }

      respond_for_index :template => 'puppet_modules', :collection => collection
    end

    api :GET, "/content_views/:id/available_puppet_module_names",
        N_("Get puppet modules names that are available to be added to the content view")
    param :id, :identifier, :desc => N_("content view numeric identifier"), :required => true
    def available_puppet_module_names
      current_names = @view.content_view_puppet_modules.map(&:name).reject { |p| p.nil? }
      repo_ids = @view.organization.library.puppet_repositories.pluck(:pulp_id)
      search_filters = [{ :terms => { :repoids => repo_ids } }]

      unless current_names.empty?
        search_filters << { :not => { :terms => { :name => current_names } } }
      end

      options = {:filters  => search_filters}

      respond_for_index :template => '../puppet_modules/names',
                        :collection => facet_search(PuppetModule, 'name', options)
    end

    api :GET, "/content_views/:id/history", N_("Show a content view's history")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    def history
      options = sort_params
      options[:load_records?] = true
      options[:filters] = [{:term => {:content_view_id => @view.id}}]

      respond_for_index :template => '../content_view_histories/index',
                        :collection => item_search(ContentViewHistory, params, options)
    end

    api :DELETE, "/content_views/:id/environments/:environment_id", N_("Remove a content view from an environment")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    param :environment_id, :number, :desc => N_("environment numeric identifier"), :required => true
    def remove_from_environment
      unless @view.environments.include?(@environment)
        fail HttpErrors::BadRequest, _("Content view '%{view}' is not in lifecycle environment '%{env}'.") %
              {view: @view.name, env: @environment.name}
      end

      task = async_task(::Actions::Katello::ContentView::RemoveFromEnvironment, @view, @environment)
      respond_for_async :resource => task
    end

    api :PUT, "/content_views/:id/remove", N_("Remove versions and/or environments from a content view and reassign systems and keys")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    param :environment_ids, :number, :desc => N_("environment numeric identifiers to be removed")
    param :content_view_version_ids, :number, :desc => N_("content view version identifiers to be deleted")
    param :system_content_view_id, :number, :desc => N_("content view to reassign orphaned systems to")
    param :system_environment_id, :number, :desc => N_("environment to reassign orphaned systems to")
    param :key_content_view_id, :number, :desc => N_("content view to reassign orphaned activation keys to")
    param :key_environment_id, :number, :desc => N_("environment to reassign orphaned activation keys to")
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
                            ).reject { |_k, v| v.nil? }
      options[:content_view_versions] = versions
      options[:content_view_environments] = cv_envs

      task = async_task(::Actions::Katello::ContentView::Remove, @view, options)
      respond_for_async :resource => task
    end

    api :DELETE, "/content_views/:id", N_("Delete a content view")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    def destroy
      task = async_task(::Actions::Katello::ContentView::Destroy, @view)
      respond_for_async :resource => task
    end

    api :POST, "/content_views/:id/copy", N_("Make copy of a content view")
    param :id, :identifier, :desc => N_("Content view numeric identifier"), :required => true
    param :name, String, :required => true, :desc => N_("New content view name")
    def copy
      new_content_view = @view.copy(params[:content_view][:name])
      respond_for_create :resource => new_content_view
    end

    private

    def find_content_view
      @view = ContentView.find(params[:id])

      if @view.default? && !%w(show history).include?(params[:action])
        fail HttpErrors::BadRequest, _("The default content view cannot be edited, published, or deleted.")
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
