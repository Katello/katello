require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Pulp3
    class SmartProxyRepositoryOrphanDistributionsTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      def setup
        @settings = SETTINGS[:katello][:content_types]
        SETTINGS[:katello][:content_types] = { file: nil }

        User.current = users(:admin)
        @primary = FactoryBot.create(:smart_proxy, :pulp_mirror, :with_pulp3)
        @repo = katello_repositories(:pulp3_file_1)
        @repo.root.update(:url => 'https://fixtures.pulpproject.org/file2/')
        ensure_creatable(@repo, @primary)
        create_repo(@repo, @primary)
      end

      def teardown
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
