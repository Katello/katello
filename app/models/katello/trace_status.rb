module Katello
  class TraceStatus < HostStatus::Status
    REQUIRE_REBOOT = 2
    REQUIRE_PROCESS_RESTART = 1
    UP_TO_DATE = 0

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
      if host.host_traces.where(:app_type => "static").any?
        REQUIRE_REBOOT
      elsif host.host_traces.where.not(:app_type => "session").any?
        REQUIRE_PROCESS_RESTART
      else
        UP_TO_DATE
      end
    end

    def relevant?(_options = {})
      # traces cannot be reported from hosts lower than el7
      return false if host.operatingsystem.try(:major).to_i.between?(1, 6)
      host.content_facet.try(:uuid)
    end
  end
end
