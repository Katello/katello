require 'katello_test_helper'

module ::Actions::Pulp3
  class RemoveOrphansTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def sync_and_reload_repo(repo, smart_proxy)
      ::Katello::Pulp3::Repository.any_instance.stubs(:fail_missing_publication).returns(nil)
      ForemanTasks.sync_task(
                ::Actions::Pulp3::Orchestration::Repository::Update,
                repo,
                smart_proxy)

      sync_args = {:smart_proxy_id => smart_proxy.id, :repo_id => repo.id}
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Sync,
        repo, smart_proxy, **sync_args)
    end

    def repo_reference(repo)
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => repo.root.id,
          :content_view_id => repo.content_view.id)
      assert repository_reference
      repository_reference
    end

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:pulp3_file_1)
      @repo.root.update(:url => 'https://fixtures.pulpproject.org/file2/')
      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)

      sync_and_reload_repo(@repo, @primary)

      @repo.root.update(
        url: "https://fixtures.pulpproject.org/file/")

      sync_and_reload_repo(@repo, @primary)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans, @primary)
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
    end

    def test_orphans_are_removed
      repository_reference = repo_reference(@repo)
      versions = ::Katello::Pulp3::Api::File.new(@primary).repository_versions_api.list(repository_reference.repository_href, {}).results.collect(&:pulp_href)
      refute_includes versions, repository_reference.repository_href + "versions/1/"
      assert_includes versions, repository_reference.repository_href + "versions/2/"
    end
  end
end
