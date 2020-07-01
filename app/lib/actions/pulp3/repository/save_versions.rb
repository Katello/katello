module Actions
  module Pulp3
    module Repository
      class SaveVersions < Pulp3::Abstract
        def plan(repository_ids, options)
          plan_self(:repository_ids => repository_ids, :tasks => options[:tasks])
        end

        def run
          version_hrefs = input[:tasks].last[:created_resources]
          repositories = input[:repository_ids].collect do |repo_id|
            ::Katello::Repository.find(repo_id)
          end

          output[:contents_changed] = false
          output[:updated_repositories] = []
          repositories.each do |repo|
            # Chop off the version number to compare base repo strings
            unversioned_href = repo.version_href[0..-2].rpartition('/').first
            new_version_href = version_hrefs.detect do |version_href|
              unversioned_href == version_href[0..-2].rpartition('/').first
            end
            # Successive incremental updates won't generate a new repo version, so fetch the latest Pulp 3 repo version
            new_version_href ||= ::Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_master!).
              repositories_api.read(repo.backend_service(SmartProxy.pulp_master).
              repository_reference.repository_href).latest_version_href

            unless new_version_href == repo.version_href
              repo.update(version_href: new_version_href)
              repo.index_content
              output[:contents_changed] = true
              output[:updated_repositories] << repo.id
            end
          end
        end
      end
    end
  end
end
