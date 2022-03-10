module Actions
  module Katello
    module ContentViewVersion
      class ResetContentViewRepositoriesFromMetadata < Actions::Base
        def plan(import:)
          import.reset_content_view_repositories!
        end
      end
    end
  end
end
