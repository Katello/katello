require 'katello_test_helper'

module Katello
  module Candlepin
    class SystemPurposeTest < ActiveSupport::TestCase
      def setup
        @system_purpose = Katello::Candlepin::SystemPurpose.new({})
      end

      def test_purpose_status
        assert_equal :not_specified, @system_purpose.purpose_status(nil, nil)
        assert_equal :not_specified, @system_purpose.purpose_status({}, nil)
        assert_equal :not_specified, @system_purpose.purpose_status(nil, [])

        assert_equal :matched, @system_purpose.purpose_status({'compliantrole' => {}}, nil)
        assert_equal :matched, @system_purpose.purpose_status({'compliantaddon' => {}}, [])

        assert_equal :mismatched, @system_purpose.purpose_status(nil, 'noncompliant_role')
        assert_equal :mismatched, @system_purpose.purpose_status(nil, ['noncompliant_addon'])
        assert_equal :mismatched, @system_purpose.purpose_status({}, ['noncompliant_addon'])
        assert_equal :mismatched, @system_purpose.purpose_status({'compliant' => {}}, ['noncompliant_addon'])
      end
    end
  end
end
