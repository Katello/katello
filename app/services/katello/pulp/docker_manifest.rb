module Katello
  module Pulp
    class DockerManifest < PulpContentUnit
      CONTENT_TYPE = "docker_manifest".freeze
    end
  end
end
