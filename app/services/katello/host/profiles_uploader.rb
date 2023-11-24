module Katello
  module Host
    class ProfilesUploader
      def initialize(profile_string:, host: nil)
        @profile_string = profile_string
        @host = host
      end

      # rubocop:disable Metrics/MethodLength
      def upload
        if @host.nil?
          Rails.logger.warn("Host was not specified; skipping")
          return false
        elsif @host.content_facet.nil? || @host.content_facet.uuid.nil?
          Rails.logger.warn("Host with ID %s has no content facet; skipping" % @host.id)
          return false
        end

        profiles = JSON.parse(@profile_string)
        #free the huge string from the memory
        @profile_string = 'TRIMMED'.freeze
        if profiles.try(:has_key?, "deb_package_profile")
          # remove this when deb_package_profile API is removed
          payload = profiles.dig("deb_package_profile", "deb_packages") || []
          import_deb_package_profile(payload)
        else
          module_streams = []
          profiles.each do |profile|
            payload = profile["profile"]
            case profile["content_type"]
            when "rpm"
              PackageProfileUploader.import_package_profile_for_host(@host.id, payload)
            when "deb"
              import_deb_package_profile(payload)
            when "enabled_repos"
              @host.import_enabled_repositories(payload)
            else
              module_streams << payload
            end
          end

          module_streams.each do |module_stream_payload|
            import_module_streams(module_stream_payload)
          end
        end

        # Just to update the internal cache
        @host.content_facet.tracer_installed?(force_update_cache: true)
        @host.content_facet.host_tools_installed?(force_update_cache: true)

        true
      end
      # rubocop:enable Metrics/MethodLength

      def trigger_applicability_generation
        if @host.nil?
          Rails.logger.warn "Host was not specified; can't trigger applicability generation"
          return
        end
        ::Katello::Host::ContentFacet.trigger_applicability_generation(@host.id)
      end

      private

      def import_module_streams(payload)
        enabled_payload = payload.map do |profile|
          profile.slice("name", "stream", "version", "context", "arch").with_indifferent_access if profile["status"] == "enabled"
        end
        enabled_payload.compact!

        @host.import_module_streams(payload)
      end

      def import_deb_package_profile(profile)
        installed_deb_ids = profile.map do |item|
          ::Katello::InstalledDeb.find_or_create_by(name: item['name'], architecture: item['architecture'], version: item['version']).id
        end
        @host.installed_deb_ids = installed_deb_ids
        @host.save!
      rescue ActiveRecord::InvalidForeignKey # this happens if the host gets deleted in between the "find_by" and "import_package_profile"
        Rails.logger.warn("Host installed package list with ID %s was not able to be written to the DB (host likely is deleted); continuing" % @host.id)
      end
    end
  end
end
