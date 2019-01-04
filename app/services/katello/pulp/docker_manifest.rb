module Katello
  module Pulp
    class DockerManifest < PulpContentUnit
      CONTENT_TYPE = "docker_manifest".freeze

      def update_model(model)
        model.update_attributes(:schema_version => backend_data[:schema_version],
                          :digest => backend_data[:digest],
                          :downloaded => backend_data[:downloaded]
         )
      end
    end
  end
end
