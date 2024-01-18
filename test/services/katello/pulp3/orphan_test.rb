require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class RepositoryOrphanBaseTest < ActiveSupport::TestCase
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

        def assert_version(repo, version)
          repo.reload
          repository_reference = Katello::Pulp3::RepositoryReference.find_by(
              :root_repository_id => repo.root.id,
              :content_view_id => repo.content_view.id)
          assert repository_reference
          assert_equal repository_reference.repository_href + version,
            repo.version_href
        end
      end

      class RepositoryOrphanTest < RepositoryOrphanBaseTest
        def setup
          User.current = users(:admin)
          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:pulp3_file_1)
          @repo.root.update(:url => 'https://fixtures.pulpproject.org/file2/')
          ensure_creatable(@repo, @primary)
          create_repo(@repo, @primary)

          @smart_proxy_service = Katello::Pulp3::SmartProxyRepository.new(@primary)

          sync_and_reload_repo(@repo, @primary)
          assert_version(@repo, "versions/1/")

          @repo.root.update(
            url: "https://fixtures.pulpproject.org/file/")

          sync_and_reload_repo(@repo, @primary)
          assert_version(@repo, "versions/2/")
        end

        def teardown
          ForemanTasks.sync_task(
              ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
          @repo.reload
        end

        def test_orphan_repository_versions
          orphans = @smart_proxy_service.orphan_repository_versions.collect { |_api, repo_versions| repo_versions }.flatten

          repo_reference = Katello::Pulp3::RepositoryReference.find_by(
              :root_repository_id => @repo.root.id,
              :content_view_id => @repo.content_view.id)

          refute_includes orphans, repo_reference.repository_href + 'versions/0/'
          assert_includes orphans, repo_reference.repository_href + 'versions/1/'
          refute_includes orphans, repo_reference.repository_href + 'versions/2/'
        end

        def test_delete_orphan_repository_versions
          delete_orphan_tasks = @smart_proxy_service.delete_orphan_repository_versions
          delete_orphan_tasks.compact.each { |task| wait_on_task(@primary, task) }
          orphans = @smart_proxy_service.orphan_repository_versions.collect { |_api, repo_versions| repo_versions }.flatten
          assert_empty orphans
        end
      end
    end
  end
end
