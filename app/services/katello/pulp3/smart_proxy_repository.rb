module Katello
  module Pulp3
    class SmartProxyRepository
      attr_accessor :smart_proxy

      def initialize(smart_proxy)
        fail "Cannot use a mirror" if smart_proxy.pulp_mirror?
        @smart_proxy = smart_proxy
      end

      def self.instance_for_type(smart_proxy)
        if smart_proxy.pulp_primary?
          SmartProxyRepository.new(smart_proxy)
        else
          SmartProxyMirrorRepository.new(smart_proxy)
        end
      end

      def ==(other)
        other.class == self.class && other.smart_proxy == smart_proxy
      end

      def current_repositories(environment_id = nil, content_view_id = nil)
        katello_repos = Katello::Repository.all
        katello_repos = katello_repos.where(:environment_id => environment_id) if environment_id
        katello_repos = katello_repos.in_content_views([content_view_id]) if content_view_id
        katello_repos = katello_repos.select { |repo| smart_proxy.pulp3_support?(repo) }
        repos_on_capsule = pulp3_enabled_repo_types.collect do |repo_type|
          repo_type.pulp3_api(smart_proxy).list_all(name_in: katello_repos.map(&:pulp_id))
        end
        repos_on_capsule.flatten!
        repo_ids = repos_on_capsule.map(&:name)
        katello_repos.select { |repo| repo_ids.include? repo.pulp_id }
      end

      def delete_orphan_repository_versions
        tasks = []
        orphan_repository_versions.each do |api, version_hrefs|
          tasks << version_hrefs.collect do |href|
            api.repository_versions_api.delete(href)
          end
        end
        tasks.flatten
      end

      def pulp3_enabled_repo_types
        Katello::RepositoryTypeManager.enabled_repository_types.values.select do |repository_type|
          smart_proxy.pulp3_repository_type_support?(repository_type)
        end
      end

      def orphan_repository_versions
        # Each key is a Pulp 3 plugin API and each value is the list of version_hrefs
        repo_version_map = {}
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_api(smart_proxy)
          version_hrefs = api.repository_versions.select { |repo_version| repo_version.number != 0 }.map(&:pulp_href)
          repo_version_map[api] = version_hrefs - ::Katello::Repository.where(version_href: version_hrefs).pluck(:version_href)
        end

        repo_version_map
      end

      def publication_for_repository_href(repository_version_href)
        api.publications_api.list({repository_version: repository_version_href}).results
      end

      def delete_orphan_repositories
        tasks = []
        orphan_repositories.each do |api, hrefs|
          tasks << hrefs.collect do |href|
            api.repositories_api.delete(href)
          end
        end
        tasks.flatten
      end

      def orphan_repositories
        repo_map = {}
        pulp3_enabled_repo_types(false).each do |repo_type|
          api = repo_type.pulp3_service_class.api(smart_proxy)
          repo_hrefs = api.list_all.map(&:pulp_href)
          repo_map[api] = repo_hrefs - ::Katello::Pulp3::RepositoryReference.where(repository_href: repo_hrefs).pluck(:repository_href)
        end
        repo_map
      end
    end
  end
end
