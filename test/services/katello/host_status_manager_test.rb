require 'katello_test_helper'

module Katello
  class HostStatusManagerTest < ActiveSupport::TestCase
    def setup
      @org = get_organization(:empty_organization)
    end

    def test_clear_syspurpose_status
      host = @org.hosts.first

      Katello::HostStatusManager::PURPOSE_STATUS.each do |status_class|
        HostStatus::Status.create(host: host, type: status_class.to_s)
      end

      assert_equal 5, host.host_statuses.count

      Katello::HostStatusManager.clear_syspurpose_status(@org.hosts)

      assert_equal 0, host.host_statuses.count
    end

    def test_update_subscription_status_to_sca
      host = @org.hosts.first
      sub_status = HostStatus::Status.create(host: host, type: Katello::SubscriptionStatus.to_s, status: Katello::SubscriptionStatus::INVALID)

      Katello::HostStatusManager.update_subscription_status_to_sca(@org.hosts)

      assert_equal Katello::SubscriptionStatus::DISABLED, sub_status.reload.status
    end
  end
end
