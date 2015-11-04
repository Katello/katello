module Katello
  class Api::V2::ContentViewsController < Api::V2::ApiController
    include Concerns::Authorization::Api::V2::ContentViewsController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_filter :find_content_view, :except => [:index, :create, :auto_complete_search]
    before_filter :find_organization, :only => [:create]
    before_filter :find_optional_organization, :only => [:index, :auto_complete_search]
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
    param_group :search, Api::V2::ApiController
    def index
      content_view_includes = [:activation_keys, :content_view_puppet_modules, :content_view_versions,
                               :environments, :organization, :repositories, components: [:content_view, :environments]]

      respond(:collection => scoped_search(index_relation.uniq, :name, :desc, :includes => content_view_includes))
    end

    def index_relation
      content_views = ContentView.readable
      content_views = content_views.where(:organization_id => @organization.id) if @organization
      content_views = content_views.in_environment(@environment) if @environment
      content_views = content_views.non_default if params[:nondefault]
      content_views = content_views.non_composite if params[:noncomposite]
      content_views = content_views.where(:name => params[:name]) if params[:name]
      content_views = content_views.where("#{ContentView.table_name}.id NOT IN (?)", params[:without]) if params[:without]
      content_views
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
      sync_task(::Actions::Katello::ContentView::Update, @view, view_params)
      respond :resource => @view.reload
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
      current_uuids = @view.content_view_puppet_modules.where("uuid is NOT NULL").pluck(:uuid)
      repositories = @view.organization.library.puppet_repositories

      query = PuppetModule.in_repositories(repositories)
      query = query.where(:name => params[:name]) if params[:name]
      query = query.where("#{PuppetModule.table_name}.uuid NOT in (?)", current_uuids) if current_uuids.present?

      respond_for_index :template => 'puppet_modules',
                        :collection => scoped_search(query, 'name', 'ASC', :resource_class => PuppetModule)
    end

    api :GET, "/content_views/:id/available_puppet_module_names",
        N_("Get puppet modules names that are available to be added to the content view")
    param :id, :identifier, :desc => N_("content view numeric identifier"), :required => true
    def available_puppet_module_names
      current_names = @view.content_view_puppet_modules.where("name is NOT NULL").pluck(:name)

      repos = @view.organization.library.puppet_repositories

      modules = PuppetModule.in_repositories(repos)
      modules = modules.where('name NOT in (?)', current_names) if current_names.present?

      respond_for_index :template => '../puppet_modules/names',
                        :collection => scoped_search(modules, 'name', 'ASC', :resource_class => PuppetModule, :group => :name)
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
