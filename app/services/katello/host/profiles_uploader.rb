module Katello
  module Host
    class ProfilesUploader
      def self.upload(profile_string:, host: nil)
        profiles = JSON.parse(profile_string)
        #free the huge string from the memory
        profile_string = 'TRIMMED'.freeze
        if host.nil?
          Rails.logger.warn("Host with ID %s not found; continuing" % host.id)
        elsif host.content_facet.nil? || host.content_facet.uuid.nil?
          Rails.logger.warn("Host with ID %s has no content facet; continuing" % host.id)
        elsif profiles.try(:has_key?, "deb_package_profile")
          # remove this when deb_package_profile API is removed
          payload = profiles.dig("deb_package_profile", "deb_packages") || []
          import_deb_package_profile(host, payload)
        else
          module_streams = []
          profiles.each do |profile|
            payload = profile["profile"]
            case profile["content_type"]
            when "rpm"
              PackageProfileUploader.import_package_profile_for_host(host.id, payload)
            when "deb"
              import_deb_package_profile(host, payload)
            when "enabled_repos"
              host.import_enabled_repositories(payload)
            else
              module_streams << payload
            end
          end

          module_streams.each do |module_stream_payload|
            import_module_streams(module_stream_payload, host)
          end

        end
      end

      private
        def self.import_module_streams(payload, host)
          enabled_payload = payload.map do |profile|
            profile.slice("name", "stream", "version", "context", "arch").with_indifferent_access if profile["status"] == "enabled"
          end
          enabled_payload.compact!

          host.import_module_streams(payload)
        end

        def self.import_deb_package_profile(host, profile)
          installed_deb_ids = profile.map do |item|
            ::Katello::InstalledDeb.find_or_create_by(name: item['name'], architecture: item['architecture'], version: item['version']).id
          end
          host.installed_deb_ids = installed_deb_ids
          host.save!
        rescue ActiveRecord::InvalidForeignKey # this happens if the host gets deleted in between the "find_by" and "import_package_profile"
          Rails.logger.warn("Host installed package list with ID %s was not able to be written to the DB (host likely is deleted), continuing" % host.id)
        end
    end
  end
end
