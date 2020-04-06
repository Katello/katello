module Katello
  module Pulp
    class DockerManifestList < PulpContentUnit
      CONTENT_TYPE = "docker_manifest_list".freeze

      def update_model(model)
        model.update(:schema_version => backend_data[:schema_version],
                          :digest => backend_data[:digest],
                          :docker_manifests => ::Katello::DockerManifest.where(:digest => backend_data[:manifests].pluck(:digest))
                         )
      end
    end
  end
end
