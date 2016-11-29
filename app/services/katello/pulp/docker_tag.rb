module Katello
  module Pulp
    class DockerTag < PulpContentUnit
      CONTENT_TYPE = "docker_tag".freeze
    end
  end
end
