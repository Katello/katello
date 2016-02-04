module Actions
  module Pulp
    module Repository
      class CopyOstreeBranch < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.ostree_branch
        end
      end
    end
  end
end
