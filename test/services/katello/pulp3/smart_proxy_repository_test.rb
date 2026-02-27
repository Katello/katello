require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Pulp3
    class SmartProxyMirrorRepositoryTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      def setup
        @old_orphan_cleanup_protected_prefix = Setting[:orphan_cleanup_protected_prefix]
      end

      def teardown
        Setting[:orphan_cleanup_protected_prefix] = @old_orphan_cleanup_protected_prefix
      end

      def test_delete_orphan_remotes
        proxy = smart_proxies(:four)
        fedora = katello_repositories(:fedora_17_x86_64)
        rhel6 = katello_repositories(:rhel_6_x86_64)
        rhel7 = katello_repositories(:rhel_7_x86_64)
        rhel7_href = '/rhel/7/href'
        smart_proxy_mirror_repo = ::Katello::Pulp3::SmartProxyMirrorRepository.new(proxy)
        # Not testing ACS remotes here
        ::Katello::SmartProxyAlternateContentSource.destroy_all

        pulp_remotes = [
          PulpRpmClient::RpmRpmRemoteResponse.new(name: rhel7.pulp_id, pulp_href: rhel7_href),
          PulpRpmClient::RpmRpmRemoteResponse.new(name: rhel6.pulp_id, pulp_href: 'rhel6'),
          PulpRpmClient::RpmRpmRemoteResponse.new(name: fedora.pulp_id, pulp_href: 'fedora'),
        ]

        smart_proxy_mirror_repo.expects(:pulp3_enabled_repo_types).once.returns([::Katello::RepositoryTypeManager.find(:yum)])
        ::Katello::SmartProxyHelper.any_instance.expects(:combined_repos_available_to_capsule).once.returns([fedora, rhel6])
        ::Katello::Pulp3::Api::Yum.any_instance.expects(:remotes_list_all).once.returns(pulp_remotes)
        ::Katello::Pulp3::Api::Yum.any_instance.expects(:delete_remote).once.with(rhel7_href).returns('rhel-7-gone')

        assert_equal ['rhel-7-gone'], smart_proxy_mirror_repo.delete_orphan_remotes
      end

      def test_delete_orphan_remotes_skips_protected_prefix
        proxy = smart_proxies(:four)
        fedora = katello_repositories(:fedora_17_x86_64)
        protected_remote_href = '/protected/href'
        orphan_remote_href = '/orphan/href'
        smart_proxy_mirror_repo = ::Katello::Pulp3::SmartProxyMirrorRepository.new(proxy)
        Setting[:orphan_cleanup_protected_prefix] = 'orphan-protected__'
        ::Katello::SmartProxyAlternateContentSource.destroy_all
        smart_proxy_mirror_repo.stubs(:write_orphan_log)

        pulp_remotes = [
          PulpRpmClient::RpmRpmRemoteResponse.new(name: "orphan-protected__#{fedora.pulp_id}", pulp_href: protected_remote_href),
          PulpRpmClient::RpmRpmRemoteResponse.new(name: fedora.pulp_id, pulp_href: '/fedora/href'),
          PulpRpmClient::RpmRpmRemoteResponse.new(name: 'orphan-remote', pulp_href: orphan_remote_href),
        ]

        smart_proxy_mirror_repo.expects(:pulp3_enabled_repo_types).once.returns([::Katello::RepositoryTypeManager.find(:yum)])
        ::Katello::SmartProxyHelper.any_instance.expects(:combined_repos_available_to_capsule).once.returns([fedora])
        ::Katello::Pulp3::Api::Yum.any_instance.expects(:remotes_list_all).once.returns(pulp_remotes)
        ::Katello::Pulp3::Api::Yum.any_instance.expects(:delete_remote).once.with(orphan_remote_href).returns('orphan-gone')

        assert_equal ['orphan-gone'], smart_proxy_mirror_repo.delete_orphan_remotes
      end

      def test_orphaned_repositories_skips_protected_prefix
        proxy = smart_proxies(:four)
        repo = katello_repositories(:pulp3_file_1)
        smart_proxy_mirror_repo = ::Katello::Pulp3::SmartProxyMirrorRepository.new(proxy)
        Setting[:orphan_cleanup_protected_prefix] = 'orphan-protected__'
        smart_proxy_mirror_repo.stubs(:write_orphan_log)
        api = mock
        repo_type = mock
        protected_repo = OpenStruct.new(name: "orphan-protected__#{repo.pulp_id}")
        known_repo = OpenStruct.new(name: repo.pulp_id)
        orphan_repo = OpenStruct.new(name: 'file-orphan')
        known_capsule_repo = OpenStruct.new(pulp_id: known_repo.name)

        smart_proxy_mirror_repo.expects(:pulp3_enabled_repo_types).once.returns([repo_type])
        repo_type.expects(:pulp3_api).with(proxy).once.returns(api)
        api.expects(:list_all).once.returns([protected_repo, known_repo, orphan_repo])
        ::Katello::SmartProxyHelper.any_instance.expects(:combined_repos_available_to_capsule).once.returns([known_capsule_repo])

        result = smart_proxy_mirror_repo.orphaned_repositories
        assert_equal [orphan_repo], result[api]
      end
    end

    class SmartProxyMirrorRepositoryOrphanRepositoryVersionsTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      def setup
        @proxy = FactoryBot.create(:smart_proxy, :pulp_mirror, :with_pulp3)
        @proxy.stubs(:pulp_primary?).returns(false)
        @smart_proxy_mirror_repo = ::Katello::Pulp3::SmartProxyMirrorRepository.new(@proxy)
      end

      def test_distributed_version_hrefs_are_skipped
        @smart_proxy_mirror_repo.expects(:report_misconfigured_repository_version).once
        ::PulpContainerClient::RepositoriesContainerVersionsApi.any_instance.expects(:delete).raises(::PulpContainerClient::ApiError.new(code: 400, message: 'Please update the necessary distributions first.'))
        @smart_proxy_mirror_repo.expects(:orphan_repository_versions).once.returns({ ::Katello::Pulp3::Api::Docker.new(@proxy) => [::PulpContainerClient::RepositoryVersionResponse.new(pulp_href: 'repo_href')] })
        @smart_proxy_mirror_repo.delete_orphan_repository_versions
      end

      def test_report_misconfigured_repository_version_yum
        fedora = katello_repositories(:fedora_17_x86_64)
        ver_href = 'ver_href'
        pub_href = 'pub_href'
        dist_href = 'dist_href'
        api = ::Katello::Pulp3::Api::Yum.new(@proxy)
        api.expects(:publications_list_all).with(repository_version: ver_href).once.returns([::PulpRpmClient::RpmRpmPublicationResponse.new(pulp_href: pub_href)])
        api.expects(:distributions_list_all).once.returns([::PulpRpmClient::RpmRpmDistributionResponse.new(pulp_href: dist_href, publication: pub_href, name: fedora.pulp_id)])

        errors = @smart_proxy_mirror_repo.report_misconfigured_repository_version(api, ver_href)
        assert_includes errors, "Completely resync (skip metadata check) repositories with the following paths to the smart proxy with ID #{@proxy.id}: " \
                                "#{fedora.relative_path}. " \
                                "Orphan cleanup is skipped for these repositories until they are fixed on smart proxy with ID #{@proxy.id}. " \
                                "Try `hammer capsule content synchronize --id #{@proxy.id} --skip-metadata-check 1 ...` using " \
                                "--repository-id with #{fedora.id}."
      end

      def test_report_misconfigured_repository_version_container
        busybox = katello_repositories(:busybox)
        ver_href = 'ver_href'
        dist_href = 'dist_href'
        api = ::Katello::Pulp3::Api::Docker.new(@proxy)
        api.expects(:distributions_list_all).once.returns([::PulpContainerClient::ContainerContainerDistributionResponse.new(pulp_href: dist_href, repository_version: ver_href, name: busybox.pulp_id)])

        errors = @smart_proxy_mirror_repo.report_misconfigured_repository_version(api, ver_href)
        assert_includes errors, "Completely resync (skip metadata check) repositories with the following paths to the smart proxy with ID #{@proxy.id}: " \
                                "#{busybox.relative_path}. " \
                                "Orphan cleanup is skipped for these repositories until they are fixed on smart proxy with ID #{@proxy.id}. " \
                                "Try `hammer capsule content synchronize --id #{@proxy.id} --skip-metadata-check 1 ...` using " \
                                "--repository-id with #{busybox.id}."
      end

      def test_report_misconfigured_repository_version_no_repos_mirror
        ver_href = 'ver_href'
        pub_href = 'pub_href'
        dist_href = 'dist_href'
        api = ::Katello::Pulp3::Api::Yum.new(@proxy)
        api.expects(:publications_list_all).with(repository_version: ver_href).once.returns([::PulpRpmClient::RpmRpmPublicationResponse.new(pulp_href: pub_href)])
        api.expects(:distributions_list_all).once.returns([::PulpRpmClient::RpmRpmDistributionResponse.new(pulp_href: dist_href, publication: pub_href, name: 'not here')])

        errors = @smart_proxy_mirror_repo.report_misconfigured_repository_version(api, ver_href)
        assert_equal errors, []
      end
    end

    class SmartProxyRepositoryOrphanRepositoryVersionsTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      def setup
        @primary = ::SmartProxy.pulp_primary
        @smart_proxy_repo = ::Katello::Pulp3::SmartProxyRepository.new(@primary)
      end

      def test_distributed_version_hrefs_are_skipped
        @smart_proxy_repo.expects(:report_misconfigured_repository_version).once
        ::PulpContainerClient::RepositoriesContainerVersionsApi.any_instance.expects(:delete).raises(::PulpContainerClient::ApiError.new(code: 400, message: 'Please update the necessary distributions first.'))
        @smart_proxy_repo.expects(:orphan_repository_versions).once.returns({ ::Katello::Pulp3::Api::Docker.new(@primary) => [::PulpContainerClient::RepositoryVersionResponse.new(pulp_href: 'repo_href')] })
        @smart_proxy_repo.delete_orphan_repository_versions
      end

      def test_report_misconfigured_repository_version_yum_default_view
        fedora = katello_repositories(:fedora_17_x86_64)
        ver_href = 'ver_href'
        pub_href = 'pub_href'
        dist_href = 'dist_href'
        api = ::Katello::Pulp3::Api::Yum.new(@primary)
        api.expects(:publications_list_all).with(repository_version: ver_href).once.returns([::PulpRpmClient::RpmRpmPublicationResponse.new(pulp_href: pub_href)])
        api.expects(:distributions_list_all).once.returns([::PulpRpmClient::RpmRpmDistributionResponse.new(pulp_href: dist_href, publication: pub_href)])

        ::Katello::Pulp3::DistributionReference.create!(path: 'path', href: dist_href, repository_id: fedora.id)

        errors = @smart_proxy_repo.report_misconfigured_repository_version(api, ver_href)
        assert_includes errors, "Completely resync (skip metadata check) or regenerate metadata for repositories with the following paths: " \
                                "#{fedora.relative_path}. Orphan cleanup is skipped for these repositories until they are fixed on smart proxy " \
                                "with ID #{@primary.id}. Try `hammer repository synchronize --skip-metadata-check 1 ...` using --id with #{fedora.id}. "
      end

      def test_report_misconfigured_repository_version_yum_content_view
        fedora = katello_repositories(:fedora_17_x86_64).clones.find { |c| c.pulp_id == 'fedora_17_library_library_view' }
        ver_href = 'ver_href'
        pub_href = 'pub_href'
        dist_href = 'dist_href'
        api = ::Katello::Pulp3::Api::Yum.new(@primary)
        api.expects(:publications_list_all).with(repository_version: ver_href).once.returns([::PulpRpmClient::RpmRpmPublicationResponse.new(pulp_href: pub_href)])
        api.expects(:distributions_list_all).once.returns([::PulpRpmClient::RpmRpmDistributionResponse.new(pulp_href: dist_href, publication: pub_href)])

        ::Katello::Pulp3::DistributionReference.create!(path: 'path', href: dist_href, repository_id: fedora.id)

        errors = @smart_proxy_repo.report_misconfigured_repository_version(api, ver_href)
        assert_includes errors, "Completely resync (skip metadata check) or regenerate metadata for repositories with the following paths: " \
                                "ACME_Corporation/dev/fedora_17_library_library_view_label. Orphan cleanup is skipped for these repositories " \
                                "until they are fixed on smart proxy with ID #{@primary.id}. Try `hammer content-view version republish-repositories ...` using --id with #{fedora.content_view_version.id}."
      end

      def test_report_misconfigured_repository_version_container_default_view
        busybox = katello_repositories(:busybox)
        ver_href = 'ver_href'
        dist_href = 'dist_href'
        api = ::Katello::Pulp3::Api::Docker.new(@primary)
        api.expects(:distributions_list_all).once.returns([::PulpContainerClient::ContainerContainerDistributionResponse.new(pulp_href: dist_href, repository_version: ver_href)])

        ::Katello::Pulp3::DistributionReference.create!(path: 'path', href: dist_href, repository_id: busybox.id)

        errors = @smart_proxy_repo.report_misconfigured_repository_version(api, ver_href)
        assert_includes errors, "Completely resync (skip metadata check) or regenerate metadata for repositories with the following paths: " \
                                "#{busybox.relative_path}. Orphan cleanup is skipped for these repositories until they are fixed on smart proxy " \
                                "with ID #{@primary.id}. Try `hammer repository synchronize --skip-metadata-check 1 ...` using --id with #{busybox.id}. "
      end

      def test_report_misconfigured_repository_version_no_repos
        ver_href = 'ver_href'
        pub_href = 'pub_href'
        dist_href = 'dist_href'
        api = ::Katello::Pulp3::Api::Yum.new(@primary)
        api.expects(:publications_list_all).with(repository_version: ver_href).once.returns([::PulpRpmClient::RpmRpmPublicationResponse.new(pulp_href: pub_href)])
        api.expects(:distributions_list_all).once.returns([::PulpRpmClient::RpmRpmDistributionResponse.new(pulp_href: dist_href, publication: pub_href)])

        errors = @smart_proxy_repo.report_misconfigured_repository_version(api, ver_href)
        assert_equal errors, []
      end
    end

    class SmartProxyMirrorRepositoryOrphanDistributionProtectionTest < ActiveSupport::TestCase
      def setup
        @old_orphan_cleanup_protected_prefix = Setting[:orphan_cleanup_protected_prefix]
        Setting[:orphan_cleanup_protected_prefix] = 'orphan-protected__'
      end

      def teardown
        Setting[:orphan_cleanup_protected_prefix] = @old_orphan_cleanup_protected_prefix
      end

      def test_orphan_distribution_returns_false_for_protected_name
        dist = OpenStruct.new(
          name: 'orphan-protected__repo',
          base_path: '/path/repo',
          publication: nil,
          repository: nil,
          repository_version: nil
        )

        refute Katello::Pulp3::SmartProxyMirrorRepository.orphan_distribution?(dist)
      end

      def test_orphan_distribution_returns_false_for_protected_base_path
        dist = OpenStruct.new(
          name: 'repo',
          base_path: 'orphan-protected__repo',
          publication: nil,
          repository: nil,
          repository_version: nil
        )

        refute Katello::Pulp3::SmartProxyMirrorRepository.orphan_distribution?(dist)
      end

      def test_orphan_distribution_non_protected_still_uses_existing_logic
        dist = OpenStruct.new(
          name: 'repo',
          base_path: '/library/repo',
          publication: nil,
          repository: nil,
          repository_version: nil
        )

        assert Katello::Pulp3::SmartProxyMirrorRepository.orphan_distribution?(dist)
      end
    end

    class SmartProxyRepositoryOrphanDistributionsTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      def setup
        skip "All tests are skipped"
        @settings = SETTINGS[:katello][:content_types]
        SETTINGS[:katello][:content_types] = { file: nil }

        User.current = users(:admin)
        @primary = SmartProxy.pulp_primary
        @repo = katello_repositories(:pulp3_file_1)
        @repo.root.update(:url => 'https://fixtures.pulpproject.org/file2/')
        ensure_creatable(@repo, @primary)
        create_repo(@repo, @primary)
      end

      def teardown
        skip "All tests are skipped"
        SETTINGS[:katello][:content_types] = @settings
      end

      def test_orphan_distributions_are_removed
        skip "Until we can figure out testing on a pulp mirror without effecting a development env"
        @repo.root.update(:url => 'https://fixtures.pulpproject.org/file/')
        ForemanTasks.sync_task(
          ::Actions::Pulp3::Repository::RefreshDistribution,
          @repo,
          @primary, contents_changed: true)

        pulp3_file_repo = Katello::Pulp3::Repository::File.new(@repo, @primary)
        distributions = pulp3_file_repo.lookup_distributions({})
        dist = distributions.last
        assert_nil dist.publication

        smart_proxy_repository = Katello::Pulp3::SmartProxyMirrorRepository.new(@primary)
        smart_proxy_repository.delete_orphan_distributions

        distributions = pulp3_file_repo.lookup_distributions({})
        refute_includes distributions, dist,
          'Distributions from capsule included an orphaned distribution that should have been deleted.'
      end

      def test_orphan_remotes_are_removed
        skip "Until we can figure out testing on a pulp mirror without effecting a development env"
        pulp3_file_repo = Katello::Pulp3::Repository.new(@repo, @primary)
        pulp3_file_repo.create

        repo_href = pulp3_file_repo.repository_reference.repository_href
        remote_href = pulp3_file_repo.repo.remote_href
        assert remote_href, 'Remote href was nil or blank.'

        repos = Katello::Pulp3::Api::Core.new(@primary).list_all.pluck(:pulp_href)
        refute_includes repos, repo_href

        smart_proxy_repository = Katello::Pulp3::SmartProxyMirrorRepository.new(@primary)
        smart_proxy_repository.delete_orphan_remotes

        remote_hrefs = Katello::Pulp3::Repository::File.remotes_list(@primary, {}).pluck(:_href)
        refute_includes remote_hrefs, remote_href,
          'Remotes from capsule included an orphaned remote that should have been deleted.'
      end
    end
  end
end
