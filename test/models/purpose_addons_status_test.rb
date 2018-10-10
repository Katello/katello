require 'katello_test_helper'

module Katello
  class PurposeAddonsStatusTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeAddonsStatus) }

    def test_status_valid
      Katello::Candlepin::Consumer.any_instance.expects(:compliant_addons?).returns(true)

      assert_equal Katello::PurposeAddonsStatus::VALID, status.to_status
      assert_equal 'Matched', status.to_label
    end

    def test_status_invalid
      Katello::Candlepin::Consumer.any_instance.expects(:compliant_addons?).returns(false)
      status.status = status.to_status

      assert_equal Katello::PurposeAddonsStatus::INVALID, status.status
      assert_equal 'Mismatched', status.to_label
    end

    def test_status_override
      assert_equal Katello::PurposeAddonsStatus::VALID, status.to_status(status_override: true)
      assert_equal Katello::PurposeAddonsStatus::INVALID, status.to_status(status_override: false)
    end
  end
end
