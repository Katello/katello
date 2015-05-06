module Actions
  module Pulp
    module Repository
      class RemoveErrata < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.errata
        end
      end
    end
  end
end
