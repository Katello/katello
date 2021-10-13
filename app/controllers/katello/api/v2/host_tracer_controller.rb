module Katello
  class Api::V2::HostTracerController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    include Katello::Concerns::Api::V2::BulkExtensions
    before_action :find_host

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    def_param_group :bulk_trace_params do
      param :included, Hash, :desc => N_("Traces to exclusively include in the action"), :required => true, :action_aware => true do
        param :search, String, :required => false, :desc => N_("Search string for traces to include")
        param :ids, Array, :required => false, :desc => N_("List of trace ids to include")
      end
      param :excluded, Hash, :desc => N_("Traces to exclude."\
                                         " All other traces will be included."\
                                         " Requires passing all: true"), :required => true, :action_aware => true do
        param :ids, Array, :required => false, :desc => N_("List of trace ids to exclude")
      end
      param :all, :bool, :desc => N_("Indicate that all of the host's traces are included."\
                                       "In this case, the included (search or ids) params are not allowed.")
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

    param_group :bulk_trace_params
    api :GET, "/hosts/:host_id/traces/helpers", N_("Obtain a list of helper commands for the given traces")
    def helpers
      traces = find_bulk_items(
        bulk_params: bulk_trace_params,
        model_scope: index_relation
      )
      result = Katello::HostTracer.helpers_for(traces)
      respond_for_show helpers: result
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
