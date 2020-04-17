require 'katello_test_helper'
require 'support/candlepin/owner_support'

module Katello
  class GlueCandlepinOwnerTestBase < ActiveSupport::TestCase
    include VCR::TestCase

    def setup
      set_user
    end
  end

  class GlueCandlepinOwnerTestSLA < GlueCandlepinOwnerTestBase
    def setup
      super
      @org = CandlepinOwnerSupport.create_organization('GlueCandlepinOwnerTestSystem_1', 'GlueCandlepinOwnerTestSystem_1')
    end

    def teardown
      super
      CandlepinOwnerSupport.destroy_organization(@org)
    end

    def test_update_candlepin_owner_service_level
      # Without any choices, should not be able to set a service level
      assert_nil @org.service_level
      e = assert_raises(RestClient::BadRequest) do
        @org.service_level = 'Premium'
      end
      refute_nil JSON.parse(e.response)['displayMessage']
      assert_nil @org.service_level

      # Should be able to set clear the default
      @org.service_level = ''
      assert_nil @org.service_level

      # ...with a nil too
      @org.service_level = nil
      assert_nil @org.service_level
    end
  end
end
