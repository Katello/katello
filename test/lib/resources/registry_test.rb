require 'katello_test_helper'

module Katello
  module Resources
    class RegistryTest < ActiveSupport::TestCase
      def test_pulp3_registry_url
        pulp_primary = SmartProxy.pulp_primary
        ::SmartProxy.expects(:pulp_primary).at_least_once.returns(pulp_primary)
        registry = Registry::RegistryResource.load_class
        assert_equal 'http://localhost:24816', registry.site
        assert_equal '/pulpcore_registry/', registry.prefix
      end

      def test_configured_pulp3_registry_url
        pulp_primary = SmartProxy.pulp_primary
        pulp_primary.expects(:setting)
          .with(SmartProxy::PULP3_FEATURE, 'container_registry_api_url')
          .returns('https://registry.example.test:8443/pulpcore_registry/')
        pulp_primary.expects(:setting)
          .with(SmartProxy::PULP3_FEATURE, 'content_app_url')
          .returns('https://content.example.test/pulp/content/')
        ::SmartProxy.expects(:pulp_primary).at_least_once.returns(pulp_primary)

        registry = Registry::RegistryResource.load_class
        assert_equal 'https://registry.example.test:8443', registry.site
        assert_equal '/pulpcore_registry/', registry.prefix
      end
    end
  end
end
