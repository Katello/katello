module Katello
  class Api::V2::HostTracerController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :find_host

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/:host_id/traces", N_("List services that need restarting on the host")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    def index
      collection = scoped_search(index_relation, :application, :asc, :resource_class => ::Katello::HostTracer)
      respond_for_index(:collection => collection)
    end

    api :PUT, "/hosts/:host_id/traces/resolve", N_("Resolve traces")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    param :trace_ids, Array, :required => true, :desc => N_("Array of Trace IDs")
    def resolve
      traces = @host.host_traces.resolvable.where(id: params[:trace_ids])
      fail HttpErrors::BadRequest, _("The requested traces were not found for this host") if traces.empty?

      result = Katello::HostTraceManager.resolve_traces(traces)

      task = ForemanTasks::Task.find(result.first.task_id)

      respond_for_async(resource: task)
    end

    protected

    def index_relation
      @host.host_traces
    end

    def total_selectable(query)
      query.where(:id => @host.host_traces.selectable).count
    end

    private

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
    end
  end
end
