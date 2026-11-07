module Actions
  module Pulp3
    module Repository
      class SaveVersions < Pulp3::Abstract
        def plan(repository_ids, options)
          plan_self(:repository_ids => repository_ids, :tasks => options[:tasks])
        end

        def run
          return if input[:tasks].empty?
          # A chunked copy runs one task per chunk, each creating its own version.
          version_hrefs = input[:tasks].flat_map { |task| task[:created_resources] }
          repositories = find_repositories(input[:repository_ids])

          output.merge!(contents_changed: false, updated_repositories: [])
          repositories.each do |repo|
            repo_backend_service = repo.backend_service(SmartProxy.pulp_primary)
            new_version_href, from_copy = version_after_copy(repo, repo_backend_service, version_hrefs)

            unless new_version_href == repo.version_href
              version = repo_backend_service.api.repository_versions_api.read(new_version_href, {fields: 'prn'})
              repo.update(version_href: new_version_href, version_prn: version.prn)
              if from_copy
                repo.index_content(:added_in_version => new_version_href)
              else
                # A looked-up version may have skipped intermediate versions; index it fully.
                repo.index_content
              end
              output[:contents_changed] = true
              output[:updated_repositories] << repo.id
            end
          end
        end

        # Returns the version to save and whether the copy task reported it.
        def version_after_copy(repo, repo_backend_service, version_hrefs)
          return [latest_version_href(repo_backend_service), false] if repo.version_href.nil?

          # Chop off the version number to compare base repo strings
          unversioned_href = repo.version_href[0..-2].rpartition('/').first
          # Could have multiple version_hrefs for the same repo depending on the copy task
          new_version_hrefs = version_hrefs.select do |version_href|
            unversioned_href == version_href[0..-2].rpartition('/').first
          end
          new_version_href = if new_version_hrefs.size > 1
                               # Find latest version_href by its version number
                               version_map(new_version_hrefs).max_by { |_href, version| version }.first
                             else
                               new_version_hrefs.first
                             end
          # Only the last chunk's version holds the last chunk's delta, so several
          # versions mean the delta is not the whole story.
          return [new_version_href, new_version_hrefs.size == 1] if new_version_href

          # Successive incremental updates won't generate a new repo version, so fetch the latest Pulp 3 repo version
          [latest_version_href(repo_backend_service), false]
        end

        def version_map(version_hrefs)
          version_map = {}
          version_hrefs.each do |href|
            version_map[href] = href.split("/")[-1].to_i
          end
          version_map
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
