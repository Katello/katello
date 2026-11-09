module Actions
  module Pulp3
    module Repository
      class SaveVersions < Pulp3::Abstract
        def plan(repository_ids, options)
          plan_self(:repository_ids => repository_ids, :tasks => options[:tasks],
                    :index_delta => options.fetch(:index_delta, false))
        end

        def run
          return if input[:tasks].empty?
          # A chunked copy runs one task per chunk, each creating its own version.
          version_hrefs = input[:tasks].flat_map { |task| task[:created_resources] }
          repositories = find_repositories(input[:repository_ids])

          output.merge!(contents_changed: false, updated_repositories: [])
          repositories.each do |repo|
            repo_backend_service = repo.backend_service(SmartProxy.pulp_primary)
            new_version_href, copy_versions = version_after_copy(repo, repo_backend_service, version_hrefs)

            previous_version_href = repo.version_href
            unless new_version_href == previous_version_href
              version = repo_backend_service.api.repository_versions_api.read(new_version_href, {fields: 'prn'})
              previous_version_prn = repo.version_prn
              repo.update(version_href: new_version_href, version_prn: version.prn)
              begin
                index_updated_version(repo, previous_version_href, new_version_href,
                                      input[:index_delta] && copy_versions.size == 1)
              rescue StandardError
                # A retry only indexes when the version changes, so it must not find the
                # updated version already saved.
                repo.update_columns(:version_href => previous_version_href,
                                    :version_prn => previous_version_prn)
                raise
              end
              output[:contents_changed] = true
              output[:updated_repositories] << repo.id
            end
          end
        end

        # The added set describes the new version only when it follows the one Katello indexes.
        # A version that skipped ahead was built on content Katello never indexed, so the
        # difference against the saved version is the delta that is missing.
        def index_updated_version(repo, previous_version_href, new_version_href, delta_possible)
          if delta_possible && !retention_policy?(repo)
            if previous_version_href.blank? ||
               version_number(new_version_href) == version_number(previous_version_href) + 1
              repo.index_content(:added_in_version => new_version_href)
            else
              repo.index_content(:added_in_version => new_version_href,
                                 :base_version => previous_version_href)
            end
          else
            # A copy can remove units the destination already had: a chunked copy's last chunk
            # need not hold the earlier chunks, and package retention prunes older packages.
            repo.index_content
          end
        end

        def retention_policy?(repo)
          repo.root.retain_package_versions_count.to_i > 0 && !repo.root.using_mirrored_content?
        end

        # Returns the version to save and the versions the copy created for it.
        def version_after_copy(repo, repo_backend_service, version_hrefs)
          created = versions_created_for(repo, repo_backend_service, version_hrefs)
          return [version_map(created).max_by { |_href, version| version }.first, created] if created.any?

          # Successive incremental updates won't generate a new repo version, so fetch the latest Pulp 3 repo version
          [latest_version_href(repo_backend_service), []]
        end

        # A repository is shared by every content view version it appears in, and the one a copy
        # created for this update may not be saved yet, so match the copy's versions by the Pulp
        # repository they belong to.
        def versions_created_for(repo, repo_backend_service, version_hrefs)
          repo_href = repo_backend_service.repository_reference&.repository_href
          if repo_href
            version_hrefs.select { |href| href.start_with?(repo_href) }.uniq
          elsif repo.version_href
            # Chop off the version number to compare base repo strings
            unversioned_href = repo.version_href[0..-2].rpartition('/').first
            version_hrefs.select { |href| unversioned_href == href[0..-2].rpartition('/').first }.uniq
          else
            []
          end
        end

        def version_map(version_hrefs)
          version_hrefs.index_with { |href| version_number(href) }
        end

        def version_number(version_href)
          version_href.split("/")[-1].to_i
        end

        def latest_version_href(repo_backend_service)
          repo_backend_service.api.repositories_api.
            read(repo_backend_service.repository_reference.repository_href).latest_version_href
        end

        def find_repositories(repository_ids)
          repository_ids.collect do |repo_id|
            if repo_id.is_a?(Hash)
              ::Katello::Repository.find(repo_id.with_indifferent_access[:id])
            else
              ::Katello::Repository.find(repo_id)
            end
          end
        end
      end
    end
  end
end
