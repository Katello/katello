require 'katello_test_helper'

module Katello
  class RepositoryTypeManagerTest < ActiveSupport::TestCase
    def setup
      ::Katello::RepositoryTypeManager.instance_variable_set(:@enabled_repository_types, {})
      @feature = SmartProxy.pulp_primary.features.detect { |feature| feature.name == 'Pulpcore' }.smart_proxy_features.first
      @feature.update(capabilities: [])
    end

    def test_enabled_repository_types_update_false
      assert_empty ::Katello::RepositoryTypeManager.enabled_repository_types(false)
    end

    def test_find_updates_enabled_repository_types
      @feature.update(capabilities: ['ansible', 'certguard', 'container', 'core', 'deb', 'file', 'rpm', 'python'])
      assert_equal :yum, ::Katello::RepositoryTypeManager.find('yum').id
      assert_equal ['yum'], ::Katello::RepositoryTypeManager.enabled_repository_types(false).keys
    end

    def test_find_calls_update_enabled_types_once
      @feature.update(capabilities: ['ansible', 'certguard', 'container', 'core', 'deb', 'file', 'rpm', 'python'])
      ::Katello::RepositoryTypeManager.expects(:update_enabled_repository_type).once
      ::Katello::RepositoryTypeManager.find('yum')
    end

    def test_check_content_type_matches_repo_type_fails_properly
      @feature.update(capabilities: ['ansible', 'certguard', 'container', 'core', 'deb', 'file', 'rpm', 'python'])
      repo = Repository.find_by(pulp_id: "pulp-uuid-rhel_6_x86_64")
      assert_raises_with_message(RuntimeError, 'Content type ostree is incompatible with repositories of type yum') do
        RepositoryTypeManager.check_content_matches_repo_type!(repo, 'ostree')
      end
    end

    def test_check_content_type_matches_repo_type_passes_properly
      @feature.update(capabilities: ['ansible', 'certguard', 'container', 'core', 'deb', 'file', 'rpm', 'python'])
      repo = Repository.find_by(pulp_id: "pulp-uuid-rhel_6_x86_64")
      RepositoryTypeManager.check_content_matches_repo_type!(repo, 'rpm')
    end
  end
end
