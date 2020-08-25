module Katello
  class Api::V2::HostTracerController < Api::V2::ApiController
    before_action :find_host, :only => :index

    api :GET, "/hosts/:host_id/traces", N_("List services that need restarting on the host")
    param :host_id, :number, :required => true, :desc => N_("ID of the host")
    def index
      collection = scoped_search(index_relation, :application, :asc, :resource_class => ::Katello::HostTracer)
      respond_for_index(:collection => collection)
    end

    api :PUT, "/traces/resolve", N_("Resolve Traces")
    param :trace_ids, Array, :required => true, :desc => N_("Array of Trace IDs")
    def resolve
      traces = Katello::HostTracer.resolvable.where(id: params[:trace_ids])

      traces.each do |trace|
        if trace.reboot_required?
          trace.helper = 'reboot'
        end
      end

      traces_by_host_id = traces.group_by(&:host_id)
      traces_by_helper = traces.group_by(&:helper)

      composers = []

      if traces_by_host_id.size < traces_by_helper.size
        traces_by_host_id.each do |host_id, trace|
          needed_traces = trace.map(&:helper).join(',')
          joined_helpers = { :helper => needed_traces }
          composers << JobInvocationComposer.for_feature(:katello_service_restart, [host_id], joined_helpers)
        end
      else
        traces_by_helper.each do |helper, trace|
          helpers = { :helper => helper }
          composers << JobInvocationComposer.for_feature(:katello_service_restart, trace.map(&:host_id), helpers)
        end
      end

      job_invocations = []

      composers.each do |composer|
        composer.trigger
        job_invocations << composer.job_invocation
      end

      render json: job_invocations
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
