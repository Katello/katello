module Katello
  module Pulp3Support
    extend ActiveSupport::Concern

    included do
      include TaskSupport
      include VCR::TestCase
    end

    PULP_TMP_DIR = "/var/lib/pulp/published/puppet_katello_test".freeze
    @repo_url = "file:///var/www/test_repos/zoo"
    @puppet_repo_url = "http://davidd.fedorapeople.org/repos/random_puppet/"
    @repo = nil

    def ensure_creatable(repo, smart_proxy)
      service = repo.backend_service(smart_proxy)
      service.class.any_instance.stubs(:backend_object_name).returns("#{repo.content_view.label}-#{repo.label}")

      tasks = []

      if (repo = service.list(name: service.backend_object_name).first)
        tasks << service.delete(repo._href)
      end

      if (publisher = service.list_publishers(name: service.backend_object_name).first)
        tasks << service.delete_publisher(publisher._href)
      end

      if (remote = service.list_remotes(name: service.backend_object_name).first)
        tasks << service.delete_remote(remote._href)
      end

      service.delete_distributions_by_paths
    end

    def create_repo(repo, smart_proxy)
      ensure_creatable(repo, smart_proxy)
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Create, repo, smart_proxy)
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, repo,
        repository_creation: true)
      repo.reload
    end
  end
end
