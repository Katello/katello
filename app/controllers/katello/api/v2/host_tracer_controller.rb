module Katello
  class Api::V2::HostTracerController < Api::V2::ApiController
    #include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_host, :only => :index

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/:host_id/tracer", N_("List servises that need restarting on the host")
    param :host_id, :identifier, :required => true, :desc => N_("ID of the host")
    def index
      collection = scoped_search(index_relation, :application, :asc, :resource_class => ::Katello::HostTracer)
      respond_for_index(:collection => collection)
    end

    protected

    def index_relation
      @host.host_traces
    end

    private

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
    end
  end
end
