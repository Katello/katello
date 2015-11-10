module Katello
  class Api::V2::EnvironmentsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    resource_description do
      resource_id 'lifecycle_environments'
      description <<-DESC
        # Description

        An environment is a basic organization structure that groups systems,
        products, repositories, etc.  Every system belongs to one environment
        and it's isolated inside so that it can see only content that is in its
        environment.

        ## Chains

        Environments are ordered into chains and their content (propducts,
        repositories, tempaltes, packages) can be moved to an environment only from its
        prior environment. You can have for example chain like:

            Library -> Development -> Testing -> Production

        Each change in an environment is done through a changeset in an action
        called promotion.

        ## Library

        Library is a special environment that has no ascendant: All the content
        starts in this environment. More chains can start from the library environment but
        no further branching of a chain is enabled.
      DESC

      api_version 'v2'
      api_base_url "/katello/api"
    end

    respond_to :json
    before_filter :find_organization, :only => [:index, :create, :paths, :auto_complete_search]
    before_filter :find_optional_organization, :only => [:show, :update, :destroy]
    before_filter :find_prior, :only => [:create]
    before_filter :find_environment, :only => [:show, :update, :destroy, :repositories]
    before_filter :find_content_view, :only => [:repositories]

    wrap_parameters :include => (KTEnvironment.attribute_names + %w(prior prior_id new_name))

    api :GET, "/environments", N_("List environments in an organization")
    api :GET, "/organizations/:organization_id/environments", N_("List environments in an organization")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :library, [true, false], :desc => N_("set true if you want to see only library environments")
    param :name, String, :desc => N_("filter only environments containing this name")
    def index
      respond(:collection => scoped_search(index_relation.uniq, :name, :desc, :resource_class => KTEnvironment))
    end

    def index_relation
      query = KTEnvironment.readable.where(:organization_id => @organization.id)
      query = query.where(:name => params[:name]) if params[:name]
      query = query.where(:library => params[:library]) if params[:library]
      query
    end

    api :GET, "/environments/:id", N_("Show an environment")
    api :GET, "/organizations/:organization_id/environments/:environment_id", N_("Show an environment")
    param :id, :number, :desc => N_("ID of the environment"), :required => true
    param :organization_id, :number, :desc => N_("ID of the organization")
    def show
      respond
    end

    api :POST, "/environments", N_("Create an environment")
    api :POST, "/organizations/:organization_id/environments", N_("Create an environment in an organization")
    param :organization_id, :number, :desc => N_("name of organization"), :required => true
    param :name, String, :desc => N_("name of the environment"), :required => true
    param :label, String, :desc => N_("label of the environment"), :required => false
    param :description, String, :desc => N_("description of the environment")
    param :prior, Integer, :deprecated => true, :desc => <<-DESC
      ID of an environment that is prior to the new environment in the chain. It has to be
      either the ID of Library or the ID of an environment at the end of a chain.
      This param exists for backwards compatibility purposes. Please use prior_id.
    DESC
    param :prior_id, Integer, :required => true, :desc => <<-DESC
      ID of an environment that is prior to the new environment in the chain. It has to be
      either the ID of Library or the ID of an environment at the end of a chain.
    DESC
    def create
      create_params = environment_params
      create_params[:label] = labelize_params(create_params)
      create_params[:organization] = @organization
      create_params[:prior] = @prior
      @environment = KTEnvironment.create!(create_params)
      @organization.kt_environments << @environment
      @organization.save!
      respond
    end

    api :PUT, "/environments/:id", N_("Update an environment")
    api :PUT, "/organizations/:organization_id/environments/:id", N_("Update an environment in an organization")
    param :id, :number, :desc => N_("ID of the environment"), :required => true
    param :organization_id, :number, :desc => N_("name of the organization")
    param :new_name, String, :desc => N_("new name to be given to the environment")
    param :description, String, :desc => N_("description of the environment")
    def update
      fail HttpErrors::BadRequest, _("Can't update the '%s' environment") % "Library" if @environment.library?
      update_params = environment_params
      update_params[:name] = params[:environment][:new_name] if params[:environment][:new_name]
      @environment.update_attributes!(update_params)
      respond
    end

    api :DELETE, "/environments/:id", N_("Destroy an environment")
    api :DELETE, "/organizations/:organization_id/environments/:id", N_("Destroy an environment in an organization")
    param :id, :number, :desc => N_("ID of the environment"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier")
    def destroy
      sync_task(::Actions::Katello::Environment::Destroy, @environment)
      respond_for_destroy
    rescue RuntimeError => e
      raise HttpErrors::BadRequest, e.message
    end

    api :GET, "/organizations/:organization_id/environments/paths", N_("List environment paths")
    param :organization_id, :number, :desc => N_("organization identifier")
    param :permission_type, String, :desc => <<-DESC
      The associated permission type. One of (readable | promotable)
      Default: readable
    DESC
    def paths
      env_paths = if params[:permission_type] == "promotable"
                    @organization.promotable_promotion_paths
                  else
                    @organization.readable_promotion_paths
                  end

      paths = env_paths.inject([]) do |result, path|
        result << { :environments => [@organization.library] + path }
      end
      paths = [{ :environments => [@organization.library] }] if paths.empty?

      collection = {
        :results => paths,
        :total => paths.size,
        :subtotal => paths.size
      }
      respond_for_index(:collection => collection, :template => :paths)
    end

    api :GET, "/organizations/:organization_id/environments/:id/repositories", "List repositories available in the environment"
    param :id, :identifier, :desc => "environment identifier"
    param :organization_id, String, :desc => "organization identifier"
    param :content_view_id, :identifier, :desc => "content view identifier", :required => false
    def repositories
      if !@environment.library? && @content_view.nil?
        fail HttpErrors::BadRequest,
              _("Cannot retrieve repos from non-library environment '%s' without a content view.") % @environment.name
      end

      @repositories = @environment.products.readable(@organization).flat_map do |p|
        p.repos(@environment, @content_view)
      end
      respond_for_index :collection => @repositories
    end

    protected

    def find_environment
      identifier = params.require(:id) || params.require(:environment).require(:id)
      @environment = KTEnvironment.find(identifier)
      fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % identifier.to_s if @environment.nil?
      @organization = @environment.organization
      @environment
    end

    def find_prior
      prior = params[:environment][:prior] || params.require(:environment).require(:prior_id)
      @prior = KTEnvironment.readable.find(prior)
      fail HttpErrors::NotFound, _("Couldn't find prior-environment '%s'") % prior.to_s if @prior.nil?
      @prior
    end

    def environment_params
      attrs = [:name, :description]
      attrs << :label if params[:action] == "create"
      parms = params.require(:environment).permit(*attrs)
      parms
    end

    def find_content_view
      @content_view = ContentView.readable.find_by_id(params[:content_view_id])
    end
  end
end
