module Katello
  class Api::V2::ContentViewsController < Api::V2::ApiController
    include Concerns::Authorization::Api::V2::ContentViewsController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_authorized_katello_resource, :except => [:index, :create, :copy, :auto_complete_search]
    before_action :ensure_non_default, :except => [:index, :create, :copy, :auto_complete_search]
    before_action :find_organization, :only => [:create]
    before_action :find_optional_organization, :only => [:index, :auto_complete_search]
    before_action :find_environment, :only => [:index, :remove_from_environment]

    wrap_parameters :include => (ContentView.attribute_names + %w(repository_ids component_ids))

    resource_description do
      api_version "v2"
    end

    def_param_group :content_view do
      param :description, String, :desc => N_("Description for the content view")
      param :repository_ids, Array, :desc => N_("List of repository ids")
      param :component_ids, Array, :desc => N_("List of component content view version ids for composite views")
      param :auto_publish, :bool, :desc => N_("Enable/Disable auto publish of composite view")
      param :solve_dependencies, :bool, :desc => N_("Solve RPM dependencies by default on Content View publish, defaults to false")
      param :import_only, :bool, :desc => N_("Designate this Content View for importing from upstream servers only. Defaults to false")
    end

    def filtered_associations
      {
        :component_ids => Katello::ContentViewVersion,
        :repository_ids => Katello::Repository
      }
    end

    api :GET, "/organizations/:organization_id/content_views", N_("List content views")
    api :GET, "/content_views", N_("List content views")
    param :organization_id, :number, :desc => N_("organization identifier")
    param :environment_id, :number, :desc => N_("environment identifier")
    param :nondefault, :bool, :desc => N_("Filter out default content views")
    param :noncomposite, :bool, :desc => N_("Filter out composite content views")
    param :composite, :bool, :desc => N_("Filter only composite content views")
    param :without, Array, :desc => N_("Do not include this array of content views")
    param :name, String, :desc => N_("Name of the content view"), :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(ContentView)
    def index
      content_view_includes = [:activation_keys, :content_view_puppet_modules, :content_view_versions,
                               :environments, :organization, :repositories]
      respond(:collection => scoped_search(index_relation.distinct, :name, :asc, :includes => content_view_includes))
    end

    def index_relation
      content_views = ContentView.readable
      content_views = content_views.where(:organization_id => @organization.id) if @organization
      content_views = content_views.in_environment(@environment) if @environment
      content_views = ::Foreman::Cast.to_bool(params[:nondefault]) ? content_views.non_default : content_views.default if params[:nondefault]
      content_views = ::Foreman::Cast.to_bool(params[:noncomposite]) ? content_views.non_composite : content_views.composite if params[:noncomposite]
      content_views = ::Foreman::Cast.to_bool(params[:composite]) ? content_views.composite : content_views.non_composite if params[:composite]
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
      @content_view = ContentView.create!(view_params) do |view|
        view.organization = @organization
        view.label ||= labelize_params(params[:content_view])
      end

      respond :resource => @content_view
    end

    api :PUT, "/content_views/:id", N_("Update a content view")
    param :id, :number, :desc => N_("Content view identifier"), :required => true
    param :name, String, :desc => N_("New name for the content view")
    param_group :content_view
    def update
      sync_task(::Actions::Katello::ContentView::Update, @content_view, view_params)
      respond :resource => @content_view.reload
    end

    api :POST, "/content_views/:id/publish", N_("Publish a content view")
    param :id, :number, :desc => N_("Content view identifier"), :required => true
    param :description, String, :desc => N_("Description for the new published content view version")
    param :major, :number, :desc => N_("Override the major version number"), :required => false
    param :minor, :number, :desc => N_("Override the minor version number"), :required => false
    param :repos_units, Array, :desc => N_("Specify the list of units in each repo"), :required => false do
      param :label, String, :desc => N_("repo label"), :required => true
      param :rpm_filenames, Array, of: String, :desc => N_("list of rpm filename strings to include in published version"), :required => true
    end
    def publish
      if params[:repos_units].present? && @content_view.composite?
        fail HttpErrors::BadRequest, _("Directly setting package lists on composite content views is not allowed. Please " \
                                     "update the components, then re-publish the composite.")
      end
      if params[:major].present? && params[:minor].present? && ContentViewVersion.find_by(:content_view_id => params[:id], :major => params[:major], :minor => params[:minor]).present?
        fail HttpErrors::BadRequest, _("A CV version already exists with the same major and minor version (%{major}.%{minor})") % {:major => params[:major], :minor => params[:minor]}
      end

      if params[:major].present? && params[:minor].nil? || params[:major].nil? && params[:minor].present?
        fail HttpErrors::BadRequest, _("Both major and minor parameters have to be used to override a CV version")
      end

      task = async_task(::Actions::Katello::ContentView::Publish, @content_view, params[:description],
                        :major => params[:major],
                        :minor => params[:minor],
                        :repos_units => params[:repos_units])
      respond_for_async :resource => task
    end

    api :GET, "/content_views/:id", N_("Show a content view")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    def show
      respond :resource => @content_view
    end

    api :GET, "/content_views/:id/available_puppet_modules",
        N_("Get puppet modules that are available to be added to the content view")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    param :name, String, :desc => N_("module name to restrict modules for"), :required => false
    def available_puppet_modules
      current_cv_puppet_modules = @content_view.content_view_puppet_modules.where("uuid is NOT NULL")
      current_uuids = current_cv_puppet_modules.pluck(:uuid)
      repositories = @content_view.organization.library.puppet_repositories
      query = PuppetModule.in_repositories(repositories)
      selected_latest_versions = []
      if params[:name]
        query = query.where(:name => params[:name])
        if current_uuids.present?
          module_by_name = current_cv_puppet_modules.find_by(:name => params[:name])
          if module_by_name&.latest_in_modules_by_author?(query)
            current_uuids.delete(module_by_name.uuid)
            selected_latest_versions.push(module_by_name.uuid)
          end
        end
      end
      query = query.where("#{PuppetModule.table_name}.pulp_id NOT in (?)", current_uuids) if current_uuids.present?
      custom_sort = ->(sort_query) { sort_query.order('author, name, sortable_version DESC') }
      sorted_records = scoped_search(query, nil, nil, :resource_class => PuppetModule, :custom_sort => custom_sort)
      if params[:name]
        sorted_records_with_use_latest = add_use_latest_records(sorted_records[:results].to_a, selected_latest_versions)
        sorted_records[:results] = sorted_records_with_use_latest
        sorted_records[:total] = sorted_records_with_use_latest.count
        sorted_records[:subtotal] = sorted_records_with_use_latest.count
      end
      respond_for_index :template => 'puppet_modules', :collection => sorted_records
    end

    api :GET, "/content_views/:id/available_puppet_module_names",
        N_("Get puppet modules names that are available to be added to the content view")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    def available_puppet_module_names
      current_names = @content_view.content_view_puppet_modules.where("name is NOT NULL").pluck(:name)

      repos = @content_view.organization.library.puppet_repositories

      modules = PuppetModule.in_repositories(repos)
      modules = modules.where('name NOT in (?)', current_names) if current_names.present?

      respond_for_index :template => '../puppet_modules/names',
                        :collection => scoped_search(modules, 'name', 'ASC', :resource_class => PuppetModule, :group => :name)
    end

    api :DELETE, "/content_views/:id/environments/:environment_id", N_("Remove a content view from an environment")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    param :environment_id, :number, :desc => N_("environment numeric identifier"), :required => true
    def remove_from_environment
      unless @content_view.environments.include?(@environment)
        fail HttpErrors::BadRequest, _("Content view '%{view}' is not in lifecycle environment '%{env}'.") %
              {view: @content_view.name, env: @environment.name}
      end

      task = async_task(::Actions::Katello::ContentView::RemoveFromEnvironment, @content_view, @environment)
      respond_for_async :resource => task
    end

    api :PUT, "/content_views/:id/remove", N_("Remove versions and/or environments from a content view and reassign systems and keys")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    param :environment_ids, Array, of: :number, :desc => N_("environment numeric identifiers to be removed")
    param :content_view_version_ids, Array, of: :number, :desc => N_("content view version identifiers to be deleted")
    param :system_content_view_id, :number, :desc => N_("content view to reassign orphaned systems to")
    param :system_environment_id, :number, :desc => N_("environment to reassign orphaned systems to")
    param :key_content_view_id, :number, :desc => N_("content view to reassign orphaned activation keys to")
    param :key_environment_id, :number, :desc => N_("environment to reassign orphaned activation keys to")
    def remove
      cv_envs = ContentViewEnvironment.where(:environment_id => params[:environment_ids],
                                             :content_view_id => params[:id]
                                            )
      versions = @content_view.versions.where(:id => params[:content_view_version_ids])

      if cv_envs.empty? && versions.empty?
        fail _("There either were no environments nor versions specified or there were invalid environments/versions specified. "\
               "Please check environment_ids and content_view_version_ids parameters.")
      end

      options = params.slice(:system_content_view_id,
                             :system_environment_id,
                             :key_content_view_id,
                             :key_environment_id
                            ).reject { |_k, v| v.nil? }.to_unsafe_h
      options[:content_view_versions] = versions
      options[:content_view_environments] = cv_envs

      task = async_task(::Actions::Katello::ContentView::Remove, @content_view, options)
      respond_for_async :resource => task
    end

    api :DELETE, "/content_views/:id", N_("Delete a content view")
    param :id, :number, :desc => N_("content view numeric identifier"), :required => true
    def destroy
      task = async_task(::Actions::Katello::ContentView::Destroy, @content_view)
      respond_for_async :resource => task
    end

    api :POST, "/content_views/:id/copy", N_("Make copy of a content view")
    param :id, :number, :desc => N_("Content view numeric identifier"), :required => true
    param :name, String, :required => true, :desc => N_("New content view name")
    def copy
      @content_view = Katello::ContentView.readable.find_by(:id => params[:id])
      throw_resource_not_found(name: 'content_view', id: params[:id]) if @content_view.blank?
      ensure_non_default
      new_content_view = @content_view.copy(params[:content_view][:name])
      respond_for_create :resource => new_content_view
    end

    private

    def  ensure_non_default
      if @content_view.default? && !%w(show history).include?(params[:action])
        fail HttpErrors::BadRequest, _("The default content view cannot be edited, published, or deleted.")
      end
    end

    def view_params
      attrs = [:name, :description, :force_puppet_environment, :auto_publish, :solve_dependencies, :import_only,
               :default, :created_at, :updated_at, :next_version, {:component_ids => []}]
      attrs.push(:label, :composite) if action_name == "create"
      if (!@content_view || !@content_view.composite?)
        attrs.push({:repository_ids => []}, :repository_ids)
      end
      params.require(:content_view).permit(*attrs).to_h
    end

    def find_environment
      return if !params.key?(:environment_id) && params[:action] == "index"
      @environment = KTEnvironment.readable.find(params[:environment_id])
    end

    def add_use_latest_records(module_records, selected_latest_versions)
      module_records.group_by(&:author).each_pair do |_author, records|
        top_rec = records[0]
        latest = top_rec.dup
        latest.version = _("Always Use Latest (currently %{version})") % { version: latest.version }
        latest.pulp_id = nil
        module_records.delete(top_rec) if selected_latest_versions.include?(top_rec.pulp_id)
        module_records.push(latest)
      end
      module_records
    end
  end
end
