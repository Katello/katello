module Katello
  module Pulp3
    class SmartProxyRepository
      attr_accessor :smart_proxy

      def initialize(smart_proxy)
        fail "Cannot use a mirror" if smart_proxy.pulp_mirror?
        @smart_proxy = smart_proxy
      end

      def self.instance_for_type(smart_proxy)
        if smart_proxy.pulp_master?
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
        repos_on_capsule = ::Katello::Pulp3::Api::Core.new(smart_proxy).list_all(name_in: katello_repos.map(&:pulp_id))
        repo_ids = repos_on_capsule.map(&:name)
        katello_repos.select { |repo| repo_ids.include? repo.pulp_id }
      end

      def core_api
        ::Katello::Pulp3::Api::Core.new(smart_proxy)
      end

      def delete_orphan_repository_versions
        orphan_repository_versions.collect do |href|
          core_api.repository_versions_api.delete(href)
        end
      end

      def pulp3_enabled_repo_types
        Katello::RepositoryTypeManager.repository_types.values.select do |repository_type|
          smart_proxy.pulp3_repository_type_support?(repository_type)
        end
      end

      def orphan_repository_versions
        version_hrefs = core_api.repository_versions
        version_hrefs - ::Katello::Repository.where(version_href: version_hrefs).pluck(:version_href)
      end
    end
  end
end
