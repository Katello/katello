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
          @primary = SmartProxy.pulp_primary
          @file_api = ::Katello::Pulp3::Api::File.new(@primary)
          @external_distribution_hrefs = []
          @external_repository_hrefs = []
          @external_remote_hrefs = []
          @external_name_counter = 0
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
          @external_distribution_hrefs.each do |href|
            task = @file_api.delete_distribution(href)
            wait_on_task(@primary, task) if task
          end

          @external_repository_hrefs.each do |href|
            task = @file_api.repositories_api.delete(href)
            wait_on_task(@primary, task) if task
          end

          @external_remote_hrefs.each do |href|
            task = @file_api.delete_remote(href)
            wait_on_task(@primary, task) if task
          end

          ensure_creatable(@repo, @primary)
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
          delete_orphan_tasks[:pulp_tasks].compact.each { |task| wait_on_task(@primary, task) }
          orphans = @smart_proxy_service.orphan_repository_versions.collect { |_api, repo_versions| repo_versions }.flatten
          assert_empty orphans
          assert_empty delete_orphan_tasks[:errors]
        end

        def test_orphan_repository_versions_skip_protected_labeled_repositories
          _protected_repo, protected_version_href = create_external_file_repo_with_version('protected-file-repo', { 'katello_orphan_cleanup' => 'false' })
          _unprotected_repo, unprotected_version_href = create_external_file_repo_with_version('orphan-file-repo')

          orphan_versions = @smart_proxy_service.orphan_repository_versions.values.flatten

          refute_includes orphan_versions, protected_version_href
          assert_includes orphan_versions, unprotected_version_href
        end

        def test_orphan_distributions_skip_protected_labeled_distributions
          protected_repo, = create_external_file_repo_with_version('protected-file-dist-repo')
          unprotected_repo, = create_external_file_repo_with_version('orphan-file-dist-repo')

          protected_distribution = create_external_file_distribution(protected_repo, { 'katello_orphan_cleanup' => 'false' })
          unprotected_distribution = create_external_file_distribution(unprotected_repo)

          orphan_distributions = @smart_proxy_service.orphan_distributions.values.flatten

          refute_includes orphan_distributions, protected_distribution.pulp_href
          assert_includes orphan_distributions, unprotected_distribution.pulp_href
        end

        private

        def deterministic_external_name(prefix)
          @external_name_counter += 1
          test_name = method_name.gsub(/[^0-9a-z_]/i, '_')
          "#{prefix}-#{test_name}-#{@external_name_counter}"
        end

        def create_external_file_repo_with_version(name_prefix, labels = nil)
          repo_name = deterministic_external_name(name_prefix)
          create_options = { name: repo_name }
          create_options[:pulp_labels] = labels if labels
          repo = @file_api.repositories_api.create(create_options)
          @external_repository_hrefs << repo.pulp_href

          remote = @file_api.remotes_api.create(
            @file_api.remote_class.new(
              name: "#{repo_name}-remote",
              url: 'https://fixtures.pulpproject.org/file2/PULP_MANIFEST',
              tls_validation: false
            )
          )
          @external_remote_hrefs << remote.pulp_href

          sync_task = @file_api.repositories_api.sync(
            repo.pulp_href,
            @file_api.repository_sync_url_class.new(remote: remote.pulp_href, mirror: true)
          )
          wait_on_task(@primary, sync_task) if sync_task
          repo = @file_api.repositories_api.read(repo.pulp_href)
          repo_versions = @file_api.versions_list_for_repository(repo.pulp_href, {})
          version = repo_versions.find { |repo_version| repo_version.number != 0 }
          assert version, "Expected synced repository #{repo.pulp_href} to have a non-zero version"
          [repo, version&.pulp_href]
        end

        def create_external_file_distribution(repo, labels = nil)
          publication_task = @file_api.publications_api.create(
            @file_api.publication_class.new(repository_version: repo.latest_version_href)
          )
          wait_on_task(@primary, publication_task) if publication_task

          publication = @file_api.publications_list_all(repository_version: repo.latest_version_href).first
          dist_name = deterministic_external_name('orphan-test-dist')
          dist_options = {
            name: dist_name,
            base_path: "orphan-test/#{dist_name}",
            publication: publication.pulp_href,
          }
          dist_options[:pulp_labels] = labels if labels
          create_task = @file_api.distributions_api.create(@file_api.distribution_class.new(dist_options))
          wait_on_task(@primary, create_task) if create_task

          distribution = @file_api.distributions_list_all(name: dist_name).first
          @external_distribution_hrefs << distribution.pulp_href
          distribution
        end
      end
    end
  end
end
