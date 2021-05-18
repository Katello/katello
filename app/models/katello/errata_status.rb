module Katello
  class ErrataStatus < HostStatus::Status
    NEEDED_SECURITY_ERRATA = 3
    NEEDED_ERRATA = 2
    UNKNOWN = 1
    UP_TO_DATE = 0

    def self.status_name
      N_("Errata")
    end

    def errata_status_installable
      @installable ||= Setting[:errata_status_installable]
    end

    def profiles_reporter_package_name
      if host.content_facet.host_tools_installed?
        Katello::Host::ContentFacet::HOST_TOOLS_PACKAGE_NAME
      else
        Katello::Host::ContentFacet::SUBSCRIPTION_MANAGER_PACKAGE_NAME
      end
    end

    def to_label(_options = {})
      case status
      when NEEDED_SECURITY_ERRATA
        errata_status_installable ? N_("Security errata installable") : N_("Security errata applicable")
      when NEEDED_ERRATA
        errata_status_installable ? N_("Non-security errata installable") : N_("Non-security errata applicable")
      when UP_TO_DATE
        N_("All errata applied")
      when UNKNOWN
        N_("No installed packages and/or enabled repositories have been reported by %s." % profiles_reporter_package_name)
      else
        N_("Unknown errata status")
      end
    end

    def to_global(_options = {})
      case status
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
      errata = if errata_status_installable
                 host.content_facet.try(:installable_errata)
               else
                 host.content_facet.try(:applicable_errata)
               end

      if errata.security.any?
        NEEDED_SECURITY_ERRATA
      elsif errata.any?
        NEEDED_ERRATA
      elsif (host.installed_packages.empty? && host.installed_debs.empty?) || host.content_facet.bound_repositories.empty?
        UNKNOWN
      else
        UP_TO_DATE
      end
    end

    def relevant?(_options = {})
      host.content_facet.try(:uuid)
    end
  end
end
