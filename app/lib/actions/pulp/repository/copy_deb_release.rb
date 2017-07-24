module Actions
  module Pulp
    module Repository
      class CopyDebRelease < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.deb_release
        end
      end
    end
  end
end
