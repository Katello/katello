module Actions
  module Katello
    module Repository
      class BulkMetadataGenerate < Actions::Base
        def plan(repos, options = {})
          sequence do
            plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::MetadataGenerate, repos.in_default_view, **options) if repos.in_default_view.any?
            plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::MetadataGenerate, repos.archived, **options) if repos.archived.any?
            plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::MetadataGenerate, repos.in_published_environments, **options) if repos.in_published_environments.any?
          end
        end
      end
    end
  end
end
