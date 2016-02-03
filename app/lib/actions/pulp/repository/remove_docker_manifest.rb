module Actions
  module Pulp
    module Repository
      class RemoveDockerManifest < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.docker_manifest
        end
      end
    end
  end
end
