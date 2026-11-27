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
                plan_self(source_repository_id: options[:source_repository].id, target_repository_id: repository.id, smart_proxy_id: smart_proxy.id,
                          reuse_version: options[:reuse_version],
                          source_version_href: options[:source_version_href],
                          source_version_prn: options[:source_version_prn],
                          source_publication_href: options[:source_publication_href],
                          source_publication_prn: options[:source_publication_prn],
                          source_content_index_id: options[:source_content_index_id])
              elsif publication_content_type && (force_publication || repository.publication_href.nil? || !repository.using_mirrored_metadata?)
                plan_action(Actions::Pulp3::Repository::CreatePublication, repository, smart_proxy, options)
              elsif !publication_content_type
                plan_self(target_repository_id: repository.id, contents_changed: options[:contents_changed], skip_publication: true)
              end
              plan_action(Actions::Pulp3::ContentGuard::Refresh, smart_proxy) unless repository.unprotected
              if Setting[:distribute_archived_cvv] || repository.environment
                plan_action(Actions::Pulp3::Repository::RefreshDistribution, repository, smart_proxy,
                            :contents_changed => options[:contents_changed], :assume_content_guard_exists => true)
              end
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
              # Prefer the hrefs the adoption proof ran against: a library sync
              # between plan and run must not hand over unproven content.
              publication_href = input[:source_publication_href] || source_repo.publication_href
              if target_repo.publication_href != publication_href && smart_proxy.pulp_primary?
                target_repo.clear_smart_proxy_sync_histories
              end
              target_repo.update!(publication_href: publication_href,
                                  publication_prn: input[:source_publication_prn] || source_repo.publication_prn)
              if input[:reuse_version]
                # A repository taking over a version takes over its content set too.
                version_href = input[:source_version_href] || source_repo.version_href
                target_repo.update!(version_href: version_href,
                                    version_prn: input[:source_version_prn] || source_repo.version_prn,
                                    # Only the index the proof ran against is known to cover this version.
                                    content_index_id: input[:source_content_index_id])
              end
            end
          end
        end
      end
    end
  end
end
