module Actions
  module Pulp3
    module Orchestration
      module Repository
        class GenerateMetadata < Pulp3::Abstract
          def plan(repository, smart_proxy, options = {})
            options[:contents_changed] = (options && options.key?(:contents_changed)) ? options[:contents_changed] : true
            publication_content_type = !::Katello::RepositoryTypeManager.find(repository.content_type).pulp3_skip_publication
            sequence do
              plan_action(Actions::Pulp3::Repository::CreateVersion, repository, smart_proxy) if options[:repository_creation]
              if options[:source_repository] && publication_content_type
                repository.update_attributes!(publication_href: options[:source_repository].publication_href)
              elsif publication_content_type
                plan_action(Actions::Pulp3::Repository::CreatePublication, repository, smart_proxy, options)
              end

              plan_action(Actions::Pulp3::Repository::RefreshDistribution, repository, smart_proxy, :contents_changed => options[:contents_changed]) if repository.environment
            end
          end
        end
      end
    end
  end
end
