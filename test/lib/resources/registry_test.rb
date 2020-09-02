require 'katello_test_helper'

module Katello
  module Resources
    class RegistryTest < ActiveSupport::TestCase
      before do
        @crane_url = "https://localhost:5000"
        SETTINGS[:katello][:container_image_registry] = {
          crane_url: @crane_url
        }
      end

      def test_pulp3_registry_url
        pulp_primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
        ::SmartProxy.expects(:pulp_primary).at_least_once.returns(pulp_primary)
        assert_equal Registry::RegistryResource.load_class.site, 'http://localhost:24816'
      end

      def test_crane_registry_url
        assert_equal Registry::RegistryResource.load_class.site, @crane_url
      end
    end
  end
end
