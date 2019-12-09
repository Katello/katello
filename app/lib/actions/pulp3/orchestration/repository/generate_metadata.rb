module Actions
  module Pulp3
    module Orchestration
      module Repository
        class GenerateMetadata < Pulp3::Abstract
          def plan(repository, smart_proxy, options = {})
            options[:contents_changed] = (options && options.key?(:contents_changed)) ? options[:contents_changed] : true
            publication_content_type = !::Katello::RepositoryTypeManager.find(repository.content_type).pulp3_skip_publication
            sequence do
              if options[:source_repository] && publication_content_type
                plan_self(source_repository_id: options[:source_repository].id, target_repository_id: repository.id)
              elsif publication_content_type
                plan_action(Actions::Pulp3::Repository::CreatePublication, repository, smart_proxy, options)
              end

              plan_action(Actions::Pulp3::Repository::RefreshDistribution, repository, smart_proxy, :contents_changed => options[:contents_changed]) if repository.environment
            end
          end

          def run
            #we don't have to actually generate a publication, we can reuse the old one
            target_repo = ::Katello::Repository.find(input[:target_repository_id])
            source_repo = ::Katello::Repository.find(input[:source_repository_id])
            target_repo.update_attributes!(publication_href: source_repo.publication_href)
          end
        end
      end
    end
  end
end
