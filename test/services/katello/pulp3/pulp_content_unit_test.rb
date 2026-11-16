require 'katello_test_helper'

module Katello
  module Pulp3
    class PulpContentUnitTest < ActiveSupport::TestCase
      def setup
        @repo = katello_repositories(:fedora_17_x86_64)
        @response = stub(as_json: { count: 1, results: [{ pulp_href: '/pulp/api/v3/content/rpm/packages/pkg-1/' }] })
      end

      def capture_page_opts
        page_opts = nil
        expectation = ::Katello::Pulp3::Rpm.stubs(:fetch_content_list)
        expectation.with do |opts|
          page_opts = opts
          true
        end
        expectation.returns(@response)
        yield
        page_opts
      end

      def test_pulp_units_batch_for_repo_queries_the_repository_version_by_default
        page_opts = capture_page_opts do
          ::Katello::Pulp3::Rpm.pulp_units_batch_for_repo(@repo, fetch_identifiers: true).to_a
        end

        assert_equal @repo.version_href, page_opts[:repository_version]
        refute page_opts.key?(:repository_version_added)
        refute page_opts.key?(:added_between)
      end

      def test_pulp_units_batch_for_repo_queries_the_added_version_when_asked
        page_opts = capture_page_opts do
          ::Katello::Pulp3::Rpm.pulp_units_batch_for_repo(
            @repo,
            added_in_version: '/pulp/api/v3/repositories/rpm/rpm/version/42/',
            fetch_identifiers: true
          ).to_a
        end

        assert_equal '/pulp/api/v3/repositories/rpm/rpm/version/42/', page_opts[:repository_version_added]
        refute page_opts.key?(:repository_version)
        refute page_opts.key?(:added_between)
      end

      def test_pulp_units_batch_for_repo_diffs_against_the_base_version_when_given_one
        page_opts = capture_page_opts do
          ::Katello::Pulp3::Rpm.pulp_units_batch_for_repo(
            @repo,
            added_in_version: '/pulp/api/v3/repositories/rpm/rpm/version/3/',
            base_version: '/pulp/api/v3/repositories/rpm/rpm/version/1/',
            fetch_identifiers: true
          ).to_a
        end

        assert_equal ['/pulp/api/v3/repositories/rpm/rpm/version/1/',
                      '/pulp/api/v3/repositories/rpm/rpm/version/3/'], page_opts[:added_between]
        refute page_opts.key?(:repository_version)
        refute page_opts.key?(:repository_version_added)
      end
    end
  end
end
