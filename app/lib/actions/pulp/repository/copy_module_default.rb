module Actions
  module Pulp
    module Repository
      class CopyModuleDefault < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.module_default
        end
      end
    end
  end
end
