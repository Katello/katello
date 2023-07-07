module Actions
  module Katello
    module OrphanCleanup
      class RemoveOrphanedContentUnits < Actions::Base
        def plan(options = {})
          plan_self(id: options[:repo_id], destroy_all: options[:destroy_all])
        end

        def run
          content_types_to_index = []
          if input[:destroy_all]
            ::Katello::RepositoryTypeManager.enabled_repository_types.each_value do |repo_type|
              content_types_to_index << repo_type.content_types_to_index
            end
          elsif input[:id]
            repo = ::Katello::Repository.find(input[:id])
            content_types_to_index = repo.repository_type.content_types_to_index
          else
            fail "Pass either a repository to determine content type or destroy_all to destroy all orphaned content units"
          end
          content_types_to_index.flatten.each do |type|
            type.model_class.orphaned.destroy_all
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
