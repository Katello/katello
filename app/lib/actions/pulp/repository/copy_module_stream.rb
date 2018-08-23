module Actions
  module Pulp
    module Repository
      class CopyModuleStream < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.module
        end
      end
    end
  end
end
