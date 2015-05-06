module Actions
  module Pulp
    module Repository
      class RemoveDockerImage < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.docker_image
        end
      end
    end
  end
end
