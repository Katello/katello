module Actions
  module Pulp
    module Repository
      class CopyPuppetModule < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.puppet_module
        end

        def criteria
          { filters: {:association => input[:clauses] } }
        end
      end
    end
  end
end
