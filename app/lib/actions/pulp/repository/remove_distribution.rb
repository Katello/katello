module Actions
  module Pulp
    module Repository
      class RemoveDistribution < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.distribution
        end
      end
    end
  end
end
