module Actions
  module Pulp
    module Repository
      class CopyDistribution < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.distribution
        end
      end
    end
  end
end
