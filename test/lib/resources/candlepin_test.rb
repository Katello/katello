require 'katello_test_helper'
require 'katello/resources/candlepin'

module Katello
  module Resources
    module Candlepin
      class UpstreamCandlepinResourceTest < ActiveSupport::TestCase
        def test_upstream_consumer_nil_current_organization
          Organization.stubs(:current).returns(nil)
          UpstreamCandlepinResource.upstream_consumer
          flunk("Failed to raise exception when current organization is nil.")
        rescue RuntimeError => e
          assert(e.message == "Current organization not set.", "Invalid message: #{e.message}")
        end

        def test_upstream_consumer_current_organization_no_imported_manifest
          Organization.stubs(:current).returns(stub(owner_details: {}))
          UpstreamCandlepinResource.upstream_consumer
          flunk("Failed to raise exception when manifest is not imported.")
        rescue RuntimeError => e
          assert(e.message == "Current organization has no manifest imported.",
                 "Invalid message: #{e.message}")
        end
      end
    end
  end
end
