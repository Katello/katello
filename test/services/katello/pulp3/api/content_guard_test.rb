require 'katello_test_helper'

module Katello
  module Pulp3
    module Api
      class ContentGuardTest < ActiveSupport::TestCase
        def setup
          @api = ContentGuard.new(SmartProxy.pulp_primary)
          @api.stubs(:ca_cert).returns('ca-cert')
          @api.stubs(:persist_if_needed)
        end

        def test_refresh_does_not_create_a_guard_that_already_exists
          found = stub(:ca_certificate => 'ca-cert')
          @api.stubs(:list).returns(stub(:results => [found]))
          @api.expects(:create).never

          @api.refresh
        end

        def test_refresh_creates_the_guard_when_it_is_missing
          @api.stubs(:list).returns(stub(:results => []))
          @api.expects(:create).once

          @api.refresh
        end

        def test_refresh_updates_the_guard_when_the_certificate_changed
          found = stub(:ca_certificate => 'old-cert', :pulp_href => '/pulp/api/v3/contentguards/certguard/rhsm/1/')
          @api.stubs(:list).returns(stub(:results => [found]))
          @api.expects(:partial_update).with(found.pulp_href).once
          @api.expects(:create).never

          @api.refresh
        end
      end
    end
  end
end
