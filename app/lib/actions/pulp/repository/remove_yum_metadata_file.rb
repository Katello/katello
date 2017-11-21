module Actions
  module Pulp
    module Repository
      class RemoveYumMetadataFile < Pulp::Repository::AbstractRemoveContent
        def content_extension
          pulp_extensions.yum_repo_metadata_file
        end
      end
    end
  end
end
