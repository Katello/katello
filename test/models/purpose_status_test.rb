require 'katello_test_helper'

module Katello
  class PurposeStatusTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeStatus) }

    def test_status_valid
      assert_equal Katello::PurposeStatus::VALID, status.to_status
    end

    def test_status_invalid_sla
      sla_status = host.get_status(Katello::PurposeSlaStatus)
      sla_status.status = Katello::PurposeSlaStatus::INVALID

      assert_equal Katello::PurposeStatus::INVALID, status.to_status
    end

    def test_status_invalid_role
      sla_status = host.get_status(Katello::PurposeRoleStatus)
      sla_status.status = Katello::PurposeRoleStatus::INVALID

      assert_equal Katello::PurposeStatus::INVALID, status.to_status
    end

    def test_status_invalid_usage
      sla_status = host.get_status(Katello::PurposeUsageStatus)
      sla_status.status = Katello::PurposeUsageStatus::INVALID

      assert_equal Katello::PurposeStatus::INVALID, status.to_status
    end

    def test_status_invalid_addons
      sla_status = host.get_status(Katello::PurposeAddonsStatus)
      sla_status.status = Katello::PurposeAddonsStatus::INVALID

      assert_equal Katello::PurposeStatus::INVALID, status.to_status
    end
  end
end
