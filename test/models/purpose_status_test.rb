require 'katello_test_helper'

module Katello
  module PurposeStatusTests
    def test_status_unknown
      purpose_mock = mock(purpose_method => :inexistent)
      Katello::Candlepin::Consumer.any_instance.expects(:system_purpose).returns(purpose_mock)

      assert_equal Katello::PurposeStatus::UNKNOWN, status.to_status
      assert_equal 'Unknown', status.to_label
    end

    def test_status_mismatched
      purpose_mock = mock(purpose_method => :mismatched)
      Katello::Candlepin::Consumer.any_instance.expects(:system_purpose).returns(purpose_mock)
      status.status = status.to_status

      assert_equal Katello::PurposeStatus::MISMATCHED, status.status
      assert_equal 'Mismatched', status.to_label
    end

    def test_status_not_specified
      purpose_mock = mock(purpose_method => :not_specified)
      Katello::Candlepin::Consumer.any_instance.expects(:system_purpose).returns(purpose_mock)
      status.status = status.to_status

      assert_equal Katello::PurposeStatus::NOT_SPECIFIED, status.status
      assert_equal 'Not specified', status.to_label
    end

    def test_status_matched
      purpose_mock = mock(purpose_method => :matched)
      Katello::Candlepin::Consumer.any_instance.expects(:system_purpose).returns(purpose_mock)
      status.status = status.to_status

      assert_equal Katello::PurposeStatus::MATCHED, status.status
      assert_equal 'Matched', status.to_label
    end

    def test_status_override
      assert_equal Katello::PurposeStatus::MISMATCHED, status.to_status(status_override: :mismatched)
      assert_equal Katello::PurposeStatus::MATCHED, status.to_status(status_override: :matched)
      assert_equal Katello::PurposeStatus::NOT_SPECIFIED, status.to_status(status_override: :not_specified)
      assert_equal Katello::PurposeStatus::UNKNOWN, status.to_status(status_override: :inexistent)
    end
  end

  class PurposeStatusTest < ActiveSupport::TestCase
    include PurposeStatusTests

    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeStatus) }
    let(:purpose_method) { :overall_status }

    def test_global_status
      assert status.to_global
    end
  end

  class PurposeSlaStatusTest < ActiveSupport::TestCase
    include PurposeStatusTests

    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeSlaStatus) }
    let(:purpose_method) { :sla_status }
  end

  class PurposeUsageStatusTest < ActiveSupport::TestCase
    include PurposeStatusTests

    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeUsageStatus) }
    let(:purpose_method) { :usage_status }
  end

  class PurposeRoleStatusTest < ActiveSupport::TestCase
    include PurposeStatusTests

    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeRoleStatus) }
    let(:purpose_method) { :role_status }
  end

  class PurposeAddonsStatusTest < ActiveSupport::TestCase
    include PurposeStatusTests

    let(:host) { FactoryBot.create(:host, :with_subscription) }
    let(:status) { host.get_status(Katello::PurposeAddonsStatus) }
    let(:purpose_method) { :addons_status }
  end
end
