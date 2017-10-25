module Actions
  module Katello
    module CapsuleContent
      class CreateRepos < ::Actions::EntryAction
        # @param capsule_content [::Katello::CapsuleContent]
        def plan(capsule_content, environment = nil, content_view = nil, repository = nil)
          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          repos_to_create(capsule_content, environment, content_view, repository).each do |repo|
            create_repo_in_pulp(capsule_content, repo)
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

        def create_repo_in_pulp(capsule_content, repository)
          ueber_cert = ::Cert::Certs.ueber_cert(repository.organization)
          relative_path = repository_relative_path(repository, capsule_content)
          checksum_type = repository.yum? ? repository.checksum_type : nil

          plan_action(Pulp::Repository::Create,
                      content_type: repository.content_type,
                      pulp_id: repository.pulp_id,
                      name: repository.name,
                      feed: repository.docker? ? repository.docker_feed_url(capsule_content.capsule) : repository.full_path(nil, true),
                      ssl_ca_cert: ::Cert::Certs.ca_cert,
                      ssl_client_cert: ueber_cert[:cert],
                      ssl_client_key: ueber_cert[:key],
                      unprotected: repository.unprotected,
                      checksum_type: checksum_type,
                      path: relative_path,
                      with_importer: true,
                      docker_upstream_name: repository.docker? ? repository.container_repository_name : nil,
                      repo_registry_id: repository.docker? ? repository.container_repository_name : nil,
                      download_policy: repository.capsule_download_policy(capsule_content.capsule),
                      capsule_id: capsule_content.capsule.id)
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
