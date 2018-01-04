module Actions
  module Pulp
    module Repository
      class RemoveDockerTag < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.docker_tag
        end
      end
    end
  end
end
