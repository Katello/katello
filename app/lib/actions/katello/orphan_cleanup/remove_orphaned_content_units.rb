module Actions
  module Katello
    module OrphanCleanup
      class RemoveOrphanedContentUnits < Actions::Base
        def run
          models = []

          ::Katello::RepositoryTypeManager.enabled_repository_types.each_value do |repo_type|
            models << repo_type.content_types_to_index
          end
          models.flatten.each do |content_type|
            content_type.model_class.orphaned.destroy_all
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
