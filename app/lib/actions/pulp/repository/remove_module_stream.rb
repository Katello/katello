module Actions
  module Pulp
    module Repository
      class RemoveModuleStream < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.module
        end
      end
    end
  end
end
