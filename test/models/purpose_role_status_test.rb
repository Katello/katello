require 'katello_test_helper'

module Katello
  class PurposeRoleStatusTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeRoleStatus) }

    def test_status_valid
      Katello::Candlepin::Consumer.any_instance.expects(:compliant_role?).returns(true)

      assert_equal Katello::PurposeRoleStatus::VALID, status.to_status
      assert_equal 'Matched', status.to_label
    end

    def test_status_invalid
      Katello::Candlepin::Consumer.any_instance.expects(:compliant_role?).returns(false)
      status.status = status.to_status

      assert_equal Katello::PurposeRoleStatus::INVALID, status.status
      assert_equal 'Mismatched', status.to_label
    end

    def test_status_override
      assert_equal Katello::PurposeRoleStatus::VALID, status.to_status(status_override: true)
      assert_equal Katello::PurposeRoleStatus::INVALID, status.to_status(status_override: false)
    end
  end
end
