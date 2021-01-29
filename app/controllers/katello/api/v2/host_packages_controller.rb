module Katello
  class Api::V2::HostPackagesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_host, :only => :index
    before_action :deprecate_katello_agent, :only => [:install, :remove, :upgrade, :upgrade_all]

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    def_param_group :packages_or_groups do
      param :packages, Array, :desc => N_("List of package names"), :required => false
      param :groups, Array, :desc => N_("List of package group names"), :required => false
    end

    api :GET, "/hosts/:host_id/packages", N_("List packages installed on the host")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Katello::InstalledPackage)
    def index
      collection = scoped_search(index_relation, :name, :asc, :resource_class => ::Katello::InstalledPackage)
      respond_for_index(:collection => collection)
    end

    def index_relation
      @host.installed_packages
    end

    def resource_class
      Katello::InstalledPackage
    end

    private

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
    end
  end
end
