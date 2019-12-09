require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class RepositoryOrphanBaseTest < ActiveSupport::TestCase
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
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:pulp3_file_1)
          @repo.root.update_attributes(:url => 'https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/file2/')
          ensure_creatable(@repo, @master)
          create_repo(@repo, @master)

          @smart_proxy_service = Katello::Pulp3::SmartProxyRepository.new(@master)

          sync_and_reload_repo(@repo, @master)
          assert_version(@repo, "versions/1/")

          @repo.root.update_attributes(
            url: "https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/file/")

          sync_and_reload_repo(@repo, @master)
          assert_version(@repo, "versions/2/")
        end

        def teardown
          ForemanTasks.sync_task(
              ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
          @repo.reload
        end

        def test_orphan_repository_versions
          orphans = @smart_proxy_service.orphan_repository_versions.collect { |_api, repo_versions| repo_versions }.flatten

          repo_reference = Katello::Pulp3::RepositoryReference.find_by(
              :root_repository_id => @repo.root.id,
              :content_view_id => @repo.content_view.id)

          assert_includes orphans, repo_reference.repository_href + 'versions/0/'
          assert_includes orphans, repo_reference.repository_href + 'versions/1/'
          refute_includes orphans, repo_reference.repository_href + 'versions/2/'
        end

        def test_delete_orphan_repository_versions
          @smart_proxy_service.delete_orphan_repository_versions
          orphans = @smart_proxy_service.orphan_repository_versions.collect { |_api, repo_versions| repo_versions }.flatten
          assert_empty orphans
        end
      end
    end
  end
end
