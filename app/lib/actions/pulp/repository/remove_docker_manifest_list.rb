module Actions
  module Pulp
    module Repository
      class RemoveDockerManifestList < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.docker_manifest_list
        end
      end
    end
  end
end
