module Actions
  module Pulp
    module Repository
      class CopyErrata < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.errata
        end
      end
    end
  end
end
