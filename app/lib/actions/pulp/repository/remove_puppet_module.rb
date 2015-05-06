module Actions
  module Pulp
    module Repository
      class RemovePuppetModule < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.puppet_module
        end
      end
    end
  end
end
