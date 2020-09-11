module Katello
  class HostTraceManager
    def self.resolve_traces(traces)
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
          composers << ::JobInvocationComposer.for_feature(:katello_service_restart, [host_id], joined_helpers)
        end
      else
        traces_by_helper.each do |helper, trace|
          helpers = { :helper => helper }
          composers << ::JobInvocationComposer.for_feature(:katello_service_restart, trace.map(&:host_id), helpers)
        end
      end

      job_invocations = []

      composers.each do |composer|
        composer.trigger
        job_invocations << composer.job_invocation
      end

      job_invocations
    end
  end
end
