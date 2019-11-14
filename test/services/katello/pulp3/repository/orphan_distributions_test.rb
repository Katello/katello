require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    class RepositoryIsOrphanDistributionTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      def test_distribution_with_publication_is_not_an_orphan
        dist = PulpFileClient::FileFileDistribution.new(
          publication: 'http://some.href')
        refute Katello::Pulp3::SmartProxyMirrorRepository.orphan_distribution?(dist)
      end

      def test_distribution_without_a_publication_is_an_orphan
        dist = PulpFileClient::FileFileDistribution.new(
          publication: nil)
        assert Katello::Pulp3::SmartProxyMirrorRepository.orphan_distribution?(dist)
      end

      def test_distribution_with_repository_and_repository_version_is_not_an_orphan
        dist = PulpAnsibleClient::AnsibleAnsibleDistribution.new(
          repository: 'http://some.href',
          repository_version: 'http://some.href/version/')
        refute Katello::Pulp3::SmartProxyMirrorRepository.orphan_distribution?(dist)
      end

      def test_distribution_without_repository_and_repository_version_is_an_orphan
        dist = PulpAnsibleClient::AnsibleAnsibleDistribution.new(
          repository: nil,
          repository_version: nil)
        assert Katello::Pulp3::SmartProxyMirrorRepository.orphan_distribution?(dist)
      end
    end
  end
end
