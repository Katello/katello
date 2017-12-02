module Actions
  module Pulp
    module Repository
      class RemoveDockerBlob < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.docker_blob
        end
      end
    end
  end
end
