module Actions
  module Pulp
    module Repository
      class CopyDockerTag < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.docker_tag
        end
      end
    end
  end
end
