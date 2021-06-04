require 'katello_test_helper'

module Katello
  module Resources
    class RegistryTest < ActiveSupport::TestCase
      def test_pulp3_registry_url
        pulp_primary = SmartProxy.pulp_primary
        ::SmartProxy.expects(:pulp_primary).at_least_once.returns(pulp_primary)
        assert_equal Registry::RegistryResource.load_class.site, 'http://localhost:24816'
      end
    end
  end
end
