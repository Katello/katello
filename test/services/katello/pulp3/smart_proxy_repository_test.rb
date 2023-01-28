require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Pulp3
    class SmartProxyMirrorRepositoryTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

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
          PulpRpmClient::RpmRpmRemoteResponse.new(name: fedora.pulp_id, pulp_href: 'fedora')
        ]

        smart_proxy_mirror_repo.expects(:pulp3_enabled_repo_types).once.returns([::Katello::RepositoryTypeManager.find(:yum)])
        ::Katello::SmartProxyHelper.any_instance.expects(:combined_repos_available_to_capsule).once.returns([fedora, rhel6])
        ::Katello::Pulp3::Api::Yum.any_instance.expects(:remotes_list).once.returns(pulp_remotes)
        ::Katello::Pulp3::Api::Yum.any_instance.expects(:delete_remote).once.with(rhel7_href).returns('rhel-7-gone')

        assert_equal ['rhel-7-gone'], smart_proxy_mirror_repo.delete_orphan_remotes
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
