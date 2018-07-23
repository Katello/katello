module Katello
  module Glue::Pulp::DockerManifestList
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def update_from_json(json)
        platforms = json[:manifests].collect do |manifest|
          platform = ::Katello::DockerManifestPlatform.where(:os => manifest[:os], :arch => manifest[:arch]).first_or_create
          manifest = ::Katello::DockerManifest.find_by_digest(manifest[:digest])
          manifest.docker_manifest_platforms << [platform] if manifest && !manifest.docker_manifest_platforms.include?(platform)
          platform
        end

        update_attributes(:schema_version => json[:schema_version],
                          :digest => json[:digest],
                          :downloaded => json[:downloaded],
                          :docker_manifests => ::Katello::DockerManifest.where(:digest => json[:manifests].pluck(:digest)),
                          :docker_manifest_platforms => ::Katello::DockerManifestPlatform.where(:id => platforms.pluck(:id))
                         )
      end
    end
  end
end
