module Actions
  module Pulp3
    module Orchestration
      module Repository
        class GenerateMetadata < Pulp3::Abstract
          def plan(repository, smart_proxy, options = {})
            force_publication = options.fetch(:force_publication, repository.publication_href.nil?)

            options[:contents_changed] = (options && options.key?(:contents_changed)) ? options[:contents_changed] : true
            publication_content_type = !::Katello::RepositoryTypeManager.find(repository.content_type).pulp3_skip_publication

            sequence do
              if options[:source_repository] && publication_content_type
                plan_self(source_repository_id: options[:source_repository].id, target_repository_id: repository.id, smart_proxy_id: smart_proxy.id)
              elsif publication_content_type && (force_publication || repository.publication_href.nil? || !repository.using_mirrored_metadata?)
                plan_action(Actions::Pulp3::Repository::CreatePublication, repository, smart_proxy, **options)
              elsif !publication_content_type
                plan_self(target_repository_id: repository.id, contents_changed: options[:contents_changed], skip_publication: true)
              end
              plan_action(Actions::Pulp3::ContentGuard::Refresh, smart_proxy) unless repository.unprotected
              plan_action(Actions::Pulp3::Repository::RefreshDistribution, repository, smart_proxy, :contents_changed => options[:contents_changed]) if Setting[:distribute_archived_cvv] || repository.environment
            end
          end

          def run
            target_repo = ::Katello::Repository.find(input[:target_repository_id])
            if input[:skip_publication]
              #Need to clear smart proxy sync histories for non-publication content_types: docker, ansible collection
              target_repo.clear_smart_proxy_sync_histories if input[:contents_changed]
            else
              #we don't have to actually generate a publication, we can reuse the old one
              source_repo = ::Katello::Repository.find(input[:source_repository_id])
              if (target_repo.publication_href != source_repo.publication_href && smart_proxy.pulp_primary?)
                target_repo.clear_smart_proxy_sync_histories
              end
              target_repo.update!(publication_href: source_repo.publication_href)
            end
          end
        end
      end
    end
  end
end
