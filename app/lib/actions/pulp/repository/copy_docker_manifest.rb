module Actions
  module Pulp
    module Repository
      class CopyDockerManifest < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.docker_manifest
        end
      end
    end
  end
end
