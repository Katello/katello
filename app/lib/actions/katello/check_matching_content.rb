module Actions
  module Katello
    module CheckMatchingContent
      def check_matching_content(new_repository, source_repositories)
        check_matching_content = ::Katello::RepositoryTypeManager.find(new_repository.content_type).metadata_publish_matching_check
        if new_repository.environment && source_repositories.count == 1 && check_matching_content
          match_check_output = plan_action(Katello::Repository::CheckMatchingContent,
                                           :source_repo_id => source_repositories.first.id,
                                           :target_repo_id => new_repository.id).output

          return match_check_output[:matching_content]
        end
        false
      end
    end
  end
end
