module Katello
  class Api::V2::FlatpakRemotesController < Katello::Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    include ::Foreman::Controller::FilterParameters

    filter_parameters :token

    before_action :find_authorized_katello_resource, :except => [:index, :create, :auto_complete_search]
    before_action :find_optional_organization, :only => [:index, :auto_complete_search]

    resource_description do
      name 'Flatpak Remotes'
    end

    def_param_group :flatpak_remote do
      param :description, String, :desc => N_("Description of the flatpak remote"), :required => false
      param :username, String, :desc => N_("Username for the flatpak remote"), :required => false
      param :token, String, :desc => N_("Token/password for the flatpak remote"), :required => false
    end

    api :GET, "/organizations/:organization_id/flatpak_remotes", N_("List flatpak remotes")
    api :GET, "/flatpak_remotes", N_("List flatpak remotes")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    param :name, String, :desc => N_("Name of the flatpak remote"), :required => false
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(FlatpakRemote)
    def index
      respond(:collection => scoped_search(index_relation, :name, :asc))
    end

    def index_relation
      remotes = FlatpakRemote.readable
      remotes = remotes.where(organization_id: @organization.id) if @organization
      remotes = remotes.where(name: params[:name]) if params[:name]
      remotes = remotes.where(label: params[:label]) if params[:label]
      remotes
    end

    api :GET, "/flatpak_remotes/:id", N_("Show a flatpak remote")
    api :GET, "/organizations/:organization_id/flatpak_remotes/:id", N_("Show a flatpak remote")
    param :id, :number, :desc => N_("Flatpak remote numeric identifier"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier")
    def show
      respond :resource => @flatpak_remote
    end

    api :POST, "/flatpak_remotes", N_("Create a flatpak remote")
    param :name, String, :desc => N_("name"), :required => true
    param :url, String, :desc => N_("Base URL of the flatpak registry index, ex: https://flatpaks.redhat.io/rhel/ , https://registry.fedoraproject.org/."), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param_group :flatpak_remote
    def create
      flatpak_remote = FlatpakRemote.new(flatpak_remote_params)
      flatpak_remote.save!
      respond_for_create(resource: flatpak_remote)
    end

    api :PUT, "/flatpak_remotes/:id", N_("Update a flatpak remote")
    param_group :flatpak_remote
    param :id, :number, :desc => N_("Flatpak remote numeric identifier"), :required => true
    param :name, String, :desc => N_("name")
    param :url, String, :desc => N_("Base URL of the flatpak registry index, ex: https://flatpaks.redhat.io/rhel/ , https://registry.fedoraproject.org/.")
    def update
      @flatpak_remote.update!(flatpak_remote_params)
      respond_for_show(:resource => @flatpak_remote)
    end

    api :DELETE, "/flatpak_remotes/:id", N_("Delete a flatpak remote")
    param :id, :number, :desc => N_("Flatpak remote numeric identifier"), :required => true
    def destroy
      @flatpak_remote.destroy
    end

    api :POST, "/flatpak_remotes/:id/scan", N_("Scan a flatpak remote")
    param :id, :number, :desc => N_("Flatpak remote numeric identifier"), :required => true
    def scan
      task = async_task(::Actions::Katello::Flatpak::ScanRemote, @flatpak_remote)
      respond_for_async :resource => task
    end

    def default_sort
      %w(name asc)
    end

    def flatpak_remote_params
      params.require(:flatpak_remote).permit(:name, :url, :description, :organization_id, :username, :token)
    end
  end
end
