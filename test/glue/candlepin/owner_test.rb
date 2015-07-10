require 'katello_test_helper'
require 'support/candlepin/owner_support'

module Katello
  class GlueCandlepinOwnerTestBase < ActiveSupport::TestCase
    def self.before_suite
      @loaded_fixtures = load_fixtures

      User.current = User.find(@loaded_fixtures['users']['admin']['id'])
      VCR.insert_cassette('glue_candlepin_owner', :match_requests_on => [:path, :params, :method, :body_json])
    end

    def self.after_suite
      super
    ensure
      VCR.eject_cassette
    end
  end

  class GlueCandlepinOwnerTestSLA < GlueCandlepinOwnerTestBase
    def self.before_suite
      super
      @@org = CandlepinOwnerSupport.create_organization('GlueCandlepinOwnerTestSystem_1', 'GlueCandlepinOwnerTestSystem_1')
    end

    def self.after_suite
      super
      CandlepinOwnerSupport.destroy_organization(@@org.id)
    end

    def test_update_candlepin_owner_service_level
      # Without any choices, should not be able to set a service level
      assert_equal nil, @@org.service_level
      e = assert_raises(RestClient::BadRequest) do
        @@org.service_level = 'Premium'
      end
      refute_nil JSON.parse(e.response)['displayMessage']
      assert_equal nil, @@org.service_level

      # Should be able to set clear the default
      @@org.service_level = ''
      assert_equal nil, @@org.service_level

      # ...with a nil too
      @@org.service_level = nil
      assert_equal nil, @@org.service_level
    end
  end
end
