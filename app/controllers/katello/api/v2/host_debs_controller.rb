module Katello
  class Api::V2::HostDebsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_host

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/:host_id/debs", N_("List deb packages installed on the host")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param_group :search, Api::V2::ApiController
    def index
      collection = scoped_search(index_relation, :name, :asc, :resource_class => ::Katello::InstalledDeb)
      respond_for_index(:collection => collection)
    end

    def index_relation
      @host.installed_debs
    end

    def resource_class
      Katello::InstalledDeb
    end

    private

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
    end
  end
end
