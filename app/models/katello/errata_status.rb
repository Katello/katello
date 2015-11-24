module Katello
  class ErrataStatus < HostStatus::Status
    NEEDED_SECURITY_ERRATA = 3
    NEEDED_ERRATA = 2
    UNKNOWN = 1
    UP_TO_DATE = 0

    def self.status_name
      N_("Errata Status")
    end

    def to_label(_options = {})
      case to_status
      when NEEDED_SECURITY_ERRATA
        N_("Security errata applicable")
      when NEEDED_ERRATA
        N_("Non-security errata applicable")
      when UP_TO_DATE
        N_("All errata applied")
      when UNKNOWN
        N_("Could not calculate errata status, ensure host is registered and katello-agent is installed")
      else
        N_("Unknown errata status")
      end
    end

    def to_global(_options = {})
      case to_status
      when NEEDED_SECURITY_ERRATA
        ::HostStatus::Global::ERROR
      when NEEDED_ERRATA
        ::HostStatus::Global::WARN
      when UP_TO_DATE
        ::HostStatus::Global::OK
      when UNKNOWN
        ::HostStatus::Global::WARN
      else
        ::HostStatus::Global::WARN
      end
    end

    def to_status(_options = {})
      return UNKNOWN if host.content_aspect.nil?

      errata = host.content_aspect.try(:applicable_errata)
      if errata.security.any?
        NEEDED_SECURITY_ERRATA
      elsif errata.any?
        NEEDED_ERRATA
      elsif host.content_aspect.bound_repositories.empty?
        UNKNOWN
      else
        UP_TO_DATE
      end
    end

    def relevant?
      host.content_aspect
    end
  end
end
