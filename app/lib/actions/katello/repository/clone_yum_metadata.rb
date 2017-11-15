module Actions
  module Katello
    module Repository
      class CloneYumMetadata < Actions::Base
        def plan(source_repo, target_repo, options = {})
          sequence do
            # Check for matching content before indexing happens, the content in pulp is
            # actually updated, but it is not reflected in the database yet.
            output = {}
            if target_repo.environment && !options[:force_yum_metadata_regeneration]
              output = plan_action(Katello::Repository::CheckMatchingContent,
                                   :source_repo_id => source_repo.id,
                                   :target_repo_id => target_repo.id).output
            end

            plan_action(Katello::Repository::IndexContent, id: target_repo.id)

            plan_action(Katello::Repository::MetadataGenerate,
                        target_repo,
                        :source_repository => source_repo,
                        :matching_content => output[:matching_content])
          end
        end
      end
    end
  end
end
