module Actions
  module Katello
    module ContentViewVersion
      class ResetContentViewRepositoriesFromMetadata < Actions::Base
        def plan(content_view:, metadata:)
          ::Katello::Pulp3::ContentViewVersion::Import.reset_content_view_repositories_from_metadata!(content_view: content_view, metadata: metadata)
        end
      end
    end
  end
end
