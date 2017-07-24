module Actions
  module Pulp
    module Repository
      class CopyDebComponent < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.deb_component
        end
      end
    end
  end
end
