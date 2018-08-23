module Actions
  module Pulp
    module Repository
      class RemoveModuleDefault < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.module_default
        end
      end
    end
  end
end
