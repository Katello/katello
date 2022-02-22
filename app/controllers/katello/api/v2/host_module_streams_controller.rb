module Katello
  class Api::V2::HostModuleStreamsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_host

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/:host_id/module_streams", N_("List module streams available to the host")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param :status, ::Katello::HostAvailableModuleStream::API_STATES.keys, :desc => N_("Streams based on the host based on their status")
    param_group :search, Api::V2::ApiController
    def index
      collection = scoped_search(index_relation, :name, :asc, :resource_class => ::Katello::HostAvailableModuleStream)
      respond_for_index(:collection => collection)
    end

    def index_relation
      return HostAvailableModuleStream.upgradable([@host]) if params[:status] == HostAvailableModuleStream::UPGRADABLE

      rel = @host.host_available_module_streams
      if params[:sort_by] == 'installed_profiles'
        rel = rel.order([:installed_profiles, :status])
      end
      return rel if params[:status].blank?
      rel.send(::Katello::HostAvailableModuleStream::API_STATES[params[:status]])
    end

    def resource_class
      Katello::HostAvailableModuleStream
    end

    private

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
    end
  end
end
