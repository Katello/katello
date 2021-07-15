require 'katello_test_helper'

module Katello
  class RepositoryTypeManagerTest < ActiveSupport::TestCase
    def setup
      ::Katello::RepositoryTypeManager.instance_variable_set(:@enabled_repository_types, {})
      @feature = SmartProxy.pulp_primary.features.detect { |feature| feature.name == 'Pulpcore' }.smart_proxy_features.first
      @feature.update(capabilities: [])
    end

    def test_enabled_repository_types_follow_smart_proxy_capabilities
      assert_empty ::Katello::RepositoryTypeManager.enabled_repository_types
      @feature.update(capabilities: ['ansible', 'certguard', 'container', 'core', 'deb', 'file', 'rpm', 'python'])
      assert_equal ['ansible_collection', 'deb', 'docker', 'file', 'yum', 'python'].sort,
        ::Katello::RepositoryTypeManager.enabled_repository_types.keys.sort
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
  end
end
