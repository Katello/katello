module Katello
  module Registration
    class HostArtifactCleaner
      attr_reader :host

      def initialize(host:)
        @host = host
      end

      def clean!(clear_content_facet: true, preserve_for_provisioning: false)
        if host.content_facet && clear_content_facet
          host.content_facet.bound_repositories = []
          host.content_facet.applicable_errata = []

          unless preserve_for_provisioning
            host.content_facet.content_view_environments = []
            host.content_facet.kickstart_repository_id = nil
            host.content_facet.content_source = ::SmartProxy.pulp_primary
          end

          host.content_facet.save!
          Rails.logger.debug "remove_host_artifacts: marking CVEs unchanged to prevent backend update"
          host.content_facet.mark_cves_unchanged
          host.content_facet.calculate_and_import_applicability
        end

        host.get_status(::Katello::ErrataStatus).destroy
        host.get_status(::Katello::TraceStatus).destroy
        host.installed_packages.delete_all
        host.rhsm_fact_values.delete_all
      end
    end
  end
end
