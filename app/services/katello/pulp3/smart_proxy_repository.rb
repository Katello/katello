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

      def orphaned_repos
        repos_on_capsule = ::Katello::Pulp3::Repository.new(nil, smart_proxy).list({})
        repo_ids = repos_on_capsule.map(&:name)
        katello_repos.reject { |repo| repo_ids.include? repo.pulp_id }
      end

      def delete_orphaned_repos
        orphaned_repos.map { |repo| ::Katello::Pulp3::Repository.new(repo).delete }.compact
      end
    end
  end
end
