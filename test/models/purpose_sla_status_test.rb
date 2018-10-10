require 'katello_test_helper'

module Katello
  class PurposeSlaStatusTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeSlaStatus) }

    def test_status_valid
      Katello::Candlepin::Consumer.any_instance.expects(:compliant_sla?).returns(true)

      assert_equal Katello::PurposeSlaStatus::VALID, status.to_status
      assert_equal 'Matched', status.to_label
    end

    def test_status_invalid
      Katello::Candlepin::Consumer.any_instance.expects(:compliant_sla?).returns(false)
      status.status = status.to_status

      assert_equal Katello::PurposeSlaStatus::INVALID, status.status
      assert_equal 'Mismatched', status.to_label
    end

    def test_status_override
      assert_equal Katello::PurposeSlaStatus::INVALID, status.to_status(status_override: false)
      assert_equal Katello::PurposeSlaStatus::VALID, status.to_status(status_override: true)
    end
  end
end
