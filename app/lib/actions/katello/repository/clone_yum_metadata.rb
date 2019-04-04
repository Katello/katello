module Actions
  module Katello
    module Repository
      class CloneYumMetadata < Actions::Base
        def plan(source_repo, target_repo)
          sequence do
            # Check for matching content before indexing happens, the content in pulp is
            # actually updated, but it is not reflected in the database yet.
            output = {}
            if !target_repo.root.previous_changes.include?(:unprotected) &&
                target_repo.environment
              output = plan_action(Katello::Repository::CheckMatchingContent,
                                   :source_repo_id => source_repo.id,
                                   :target_repo_id => target_repo.id).output
            end

            plan_action(Katello::Repository::IndexContent, id: target_repo.id)

            plan_action(Katello::Repository::MetadataGenerate,
                        target_repo,
                        :source_repository => source_repo,
                        :matching_content => output[:matching_content])

            plan_self(:source_checksum_type => source_repo.saved_checksum_type, :target_repo_id => target_repo.id) unless source_repo.saved_checksum_type == target_repo.saved_checksum_type
          end
        end

        def finalize
          repository = ::Katello::Repository.find(input[:target_repo_id])
          source_checksum_type = input[:source_checksum_type]
          repository.update_attributes!(saved_checksum_type: source_checksum_type) if (repository && source_checksum_type)
        end
      end
    end
  end
end
