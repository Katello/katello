module Katello
  module Pulp3
    class SmartProxyRepository
      attr_accessor :smart_proxy

      def initialize(smart_proxy)
        @smart_proxy = smart_proxy
      end

      def ==(other)
        other.class == self.class && other.smart_proxy == smart_proxy
      end

      def current_repositories(environment_id = nil, content_view_id = nil)
        katello_repos = Katello::Repository.all
        katello_repos = katello_repos.where(:environment_id => environment_id) if environment_id
        katello_repos = katello_repos.in_content_views([content_view_id]) if content_view_id
        katello_repos = katello_repos.select { |repo| smart_proxy.pulp3_support?(repo) }
        repos_on_capsule = ::Katello::Pulp3::Repository.new(nil, smart_proxy).list(name_in: katello_repos.map(&:pulp_id))
        repo_ids = repos_on_capsule.map(&:name)
        katello_repos.select { |repo| repo_ids.include? repo.pulp_id }
      end

      def orphaned_repositories_for_mirror_proxies
        smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
        katello_pulp_ids = smart_proxy_helper.repos_available_to_capsule.map(&:pulp_id)
        repos_on_capsule = ::Katello::Pulp3::Repository.new(nil, smart_proxy).list({})
        repos_on_capsule.reject { |capsule_repo| katello_pulp_ids.include? capsule_repo.name }
      end

      def delete_orphaned_repositories_for_mirror_proxies
        orphaned_repositories_for_mirror_proxies.map do |repo|
          ::Katello::Pulp3::Repository.new(nil, smart_proxy).repositories_api.delete(repo.pulp_href)
        end
      end

      def delete_orphaned_distributions_for_mirror_proxies
        ::Katello::Pulp3::Repository.delete_orphan_distributions(smart_proxy)
      end

      def delete_orphaned_remotes_for_mirror_proxies
        ::Katello::Pulp3::Repository.delete_orphan_remotes(smart_proxy)
      end
    end
  end
end
