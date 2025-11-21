module Katello
  class Api::V2::HostTracerController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :find_host, except: [:bulk_auto_complete_search]
    before_action :find_organization, only: [:bulk_auto_complete_search]

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

    api :GET, "/hosts/bulk/traces/auto_complete_search", N_("Autocomplete for traces in bulk context")
    param :organization_id, :number, :desc => N_("Organization ID for scoping")
    param :search, String, :desc => N_("Search string")
    def bulk_auto_complete_search
      auto_complete_search
    end

    protected

    def index_relation
      if @host
        # Single host context
        @host.host_traces
      elsif @organization
        # Bulk context - scope to organization and viewable traces
        ::Katello::HostTracer.joins(:host)
                             .where(hosts: { organization_id: @organization.id })
                             .merge(::Host::Managed.authorized(:view_hosts))
      else
        # Fallback to authorized traces
        ::Katello::HostTracer.joins(:host)
                             .merge(::Host::Managed.authorized(:view_hosts))
      end
    end

    def total_selectable(query)
      query.where(:id => @host.host_traces.selectable).count
    end

    private

    def find_host
      @host = resource_finder(::Host::Managed.authorized(:view_hosts, ::Host::Managed), params[:host_id])
    end

    def find_organization
      @organization = Organization.find_by_id(params[:organization_id])
    end
  end
end
