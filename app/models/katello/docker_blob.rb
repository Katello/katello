module Katello
  class DockerBlob < Katello::Model
    include Concerns::PulpDatabaseUnit
    CONTENT_TYPE = "docker_blob".freeze
  end
end
