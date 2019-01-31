module Katello
  module Pulp
    class DockerBlob < PulpContentUnit
      CONTENT_TYPE = "docker_blob".freeze
    end
  end
end
