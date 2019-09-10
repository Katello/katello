require 'katello_test_helper'

module ::Actions::Pulp3
  class RemoveOrphansTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def sync_and_reload_repo(repo, smart_proxy)
      ForemanTasks.sync_task(
                ::Actions::Pulp3::Orchestration::Repository::Update,
                repo,
                smart_proxy)

      sync_args = {:smart_proxy_id => smart_proxy.id, :repo_id => repo.id}
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Sync,
        repo, smart_proxy, sync_args)
    end

    def repo_reference(repo)
      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => repo.root.id,
          :content_view_id => repo.content_view.id)
      assert repository_reference
      repository_reference
    end

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:pulp3_file_1)
      @repo.root.update_attributes(:url => 'https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/file2/')
      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)

      sync_and_reload_repo(@repo, @master)

      @repo.root.update_attributes(
        url: "https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/file/")

      sync_and_reload_repo(@repo, @master)

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans, @master)
    end

    def teardown
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
      @repo.reload
    end

    def test_orphans_are_removed
      repository_reference = repo_reference(@repo)
      versions = ::Katello::Pulp3::Repository.new(@repo, @master).repository_versions_api.list(repository_reference.repository_href, {}).results.collect(&:_href)
      refute_includes versions, repository_reference.repository_href + "versions/1/"
      assert_includes versions, repository_reference.repository_href + "versions/2/"
    end
  end
end
