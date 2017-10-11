module Katello
  module Pulp
    class DockerManifestList < PulpContentUnit
      CONTENT_TYPE = "docker_manifest_list".freeze
    end
  end
end
