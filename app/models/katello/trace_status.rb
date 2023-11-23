module Katello
  class TraceStatus < HostStatus::Status
    REQUIRE_REBOOT = 2
    REQUIRE_PROCESS_RESTART = 1
    UP_TO_DATE = 0
    UNKNOWN = -1

    def self.status_name
      N_("Traces")
    end

    def to_label(_options = {})
      case to_status
      when REQUIRE_REBOOT
        N_("Reboot required")
      when REQUIRE_PROCESS_RESTART
        N_("One or more processes require restarting")
      when UP_TO_DATE
        N_("No processes require restarting")
      else
        N_("Unknown traces status")
      end
    end

    def to_global(_options = {})
      case to_status
      when REQUIRE_REBOOT
        ::HostStatus::Global::ERROR
      when REQUIRE_PROCESS_RESTART
        ::HostStatus::Global::WARN
      when UP_TO_DATE
        ::HostStatus::Global::OK
      else
        ::HostStatus::Global::WARN
      end
    end

    def to_status(_options = {})
      traces = host.host_traces.pluck(:app_type)
      traces.delete(Katello::HostTracer::TRACE_APP_TYPE_SESSION)

      if traces.include?(Katello::HostTracer::TRACE_APP_TYPE_STATIC)
        REQUIRE_REBOOT
      elsif !traces.empty?
        REQUIRE_PROCESS_RESTART
      else
        UP_TO_DATE
      end
    end

    def relevant?(_options = {})
      # traces cannot be reported from hosts lower than el7
      return false if host.operatingsystem.try(:major).to_i.between?(1, 6) || !host.content_facet&.tracer_installed?
      host.content_facet.try(:uuid).present?
    end
  end
end
