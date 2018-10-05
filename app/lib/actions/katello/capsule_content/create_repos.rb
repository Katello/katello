module Actions
  module Katello
    module CapsuleContent
      class CreateRepos < ::Actions::EntryAction
        # @param capsule_content [::Katello::CapsuleContent]
        def plan(capsule_content, environment = nil, content_view = nil, repository = nil)
          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          repos_to_create(capsule_content, environment, content_view, repository).each do |repo|
            plan_action(Pulp::Repository::Create, repo, capsule_content.capsule)
          end
        end

        def repos_to_create(capsule_content, environment, content_view, repository)
          repos = []
          current_repos_on_capsule = capsule_content.current_repositories(environment, content_view)

          if repository
            unless current_repos_on_capsule.include?(repository)
              repos << repository
            end
          else
            list_of_repos_to_sync = capsule_content.repos_available_to_capsule(environment, content_view)
            repos = list_of_repos_to_sync - current_repos_on_capsule
          end
          repos
        end

        def repository_relative_path(repository, capsule_content)
          if repository.is_a? ::Katello::ContentViewPuppetEnvironment
            repository.generate_puppet_path(capsule_content.capsule)
          elsif repository.puppet? && (repository.is_a? ::Katello::Repository)
            nil
          else
            repository.relative_path
          end
        end
      end
    end
  end
end
