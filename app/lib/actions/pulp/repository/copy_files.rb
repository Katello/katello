module Actions
  module Pulp
    module Repository
      class CopyFiles < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.file
        end
      end
    end
  end
end
