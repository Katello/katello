module Actions
  module Pulp
    module Repository
      class CopyYumMetadataFile < Pulp::Repository::AbstractCopyContent
        def content_extension
          pulp_extensions.yum_repo_metadata_file
        end
      end
    end
  end
end
