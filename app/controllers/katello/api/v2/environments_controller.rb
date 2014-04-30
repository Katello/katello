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
  class Api::V2::EnvironmentsController < Api::V2::ApiController

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
      api_base_url "#{Katello.config.url_prefix}/api"
    end

    respond_to :json
    before_filter :find_organization, :only => [:index, :create, :paths]
    before_filter :find_optional_organization, :only => [:show, :update, :destroy]
    before_filter :find_prior, :only => [:create]
    before_filter :find_environment, :only => [:show, :update, :destroy, :repositories]
    before_filter :find_content_view, :only => [:repositories]
    before_filter :load_search_service, :only => [:index]

    wrap_parameters :include => (KTEnvironment.attribute_names + %w(prior new_name))

    api :GET, "/environments", "List environments in an organization"
    api :GET, "/organizations/:organization_id/environments", "List environments in an organization"
    param :organization_id, String, :desc => "organization identifier", :required => true
    param :library, [true, false], :desc => "set true if you want to see only library environments"
    param :name, String, :desc => "filter only environments containing this name"
    def index
      filters = []

      filters << {:terms => {:organization_id => [@organization.id]}}
      # See http://projects.theforeman.org/issues/4405
      filters << {:terms => {:name => [params[:name].downcase]}} if params[:name]
      filters << {:terms => {:library => [params[:library]]}} if params[:library].present?

      options = {
        :filters => filters,
        :load_records? => true
      }
      respond_for_index(:collection => item_search(KTEnvironment, params, options))
    end

    api :GET, "/environments/:id", "Show an environment"
    api :GET, "/organizations/:organization_id/environments/:environment_id", "Show an environment"
    param :id, :number, :desc => "ID of the environment", :required => true
    param :organization_id, String, :desc => "ID of the organization"
    def show
      respond
    end

    api :POST, "/environments", "Create an environment"
    api :POST, "/organizations/:organization_id/environments", "Create an environment in an organization"
    param :organization_id, String, :desc => "name of organization", :required => true
    param :name, String, :desc => "name of the environment", :required => true
    param :description, String, :desc => "description of the environment"
    param :prior, String, :required => true, :desc => <<-DESC
      Name of an environment that is prior to the new environment in the chain. It has to be
      either 'Library' or an environment at the end of a chain.
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

    api :PUT, "/environments/:id", "Update an environment"
    api :PUT, "/organizations/:organization_id/environments/:id", "Update an environment in an organization"
    param :id, :number, :desc => "ID of the environment", :required => true
    param :organization_id, String, :desc => "name of the organization"
    param :new_name, String, :desc => "new name to be given to the environment"
    param :description, String, :desc => "description of the environment"
    param :prior, String, :desc => <<-DESC
      Name of an environment that is prior to the new environment in the chain. It has to be
      either 'Library' or an environment at the end of a chain.
    DESC
    def update
      fail HttpErrors::BadRequest, _("Can't update the '%s' environment") % "Library" if @environment.library?
      update_params = environment_params
      update_params[:name] = params[:environment][:new_name] if params[:environment][:new_name]
      update_params[:label] = labelize_params(update_params) if update_params[:name]
      @environment.update_attributes!(update_params)
      respond
    end

    api :DELETE, "/environments/:id", "Destroy an environment"
    api :DELETE, "/organizations/:organization_id/environments/:id", "Destroy an environment in an organization"
    param :id, :number, :desc => "ID of the environment", :required => true
    param :organization_id, String, :desc => "organization identifier"
    def destroy
      if @environment.is_deletable?
        @environment.destroy
        respond_for_destroy
      else
        fail HttpErrors::BadRequest,
          _("Environment %s has a successor. Only the last environment on a path can be deleted.") % @environment.name
      end
    end

    api :GET, "/organizations/:organization_id/environments/paths", "List environment paths"
    param :organization_id, String, :desc => "organization identifier"
    def paths
      paths = @organization.promotion_paths.inject([]) do |result, path|
        result << { :environments => [@organization.library] + path }
      end
      paths = [{ :environments => [@organization.library] }] if paths.empty?

      respond_for_index(:collection => paths, :template => :paths)
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
      prior = params.require(:environment).require(:prior)
      @prior = KTEnvironment.find(prior)
      fail HttpErrors::NotFound, _("Couldn't find prior-environment '%s'") % prior.to_s if @prior.nil?
      @prior
    end

    def environment_params
      attrs = [:name, :description]
      attrs.push(:label, :prior) if params[:action] == "create"
      parms = params.require(:environment).permit(*attrs)
      parms
    end

    def find_content_view
      @content_view = ContentView.readable.find_by_id(params[:content_view_id])
    end
  end

end
