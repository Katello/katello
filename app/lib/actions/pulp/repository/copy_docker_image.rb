module Actions
  module Pulp
    module Repository
      class CopyDockerImage < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.docker_image
        end
      end
    end
  end
end
