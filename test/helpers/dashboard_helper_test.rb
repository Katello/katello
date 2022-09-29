require 'test_helper'
require 'katello_test_helper'

class DashboardHelperTest < ActiveSupport::TestCase
  include ApplicationHelper
  include ::Katello::Concerns::DashboardHelperExtensions

  def setup
    User.current = User.anonymous_api_admin
    @library = katello_environments(:library)
    ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
    @host = FactoryBot.build(:host, :with_content, :with_subscription,
                               :content_view => katello_content_views(:library_dev_view),
                               :lifecycle_environment => katello_environments(:library), :id => 101)
    @host.organization = taxonomies(:organization1)
    @host.organization.stubs(:simple_content_access?).returns(false)
    @host.save!
    Organization.current = @host.organization
  end

  def test_total_host_count
    total = total_host_count
    refute total.nil?
    assert_equal 1, total
  end

  def test_partial_consumer_count
    @host.subscription_facet.update_subscription_status('partial')
    partial = partial_consumer_count
    assert_equal 1, partial
  end

  def test_valid_consumer_count
    @host.subscription_facet.update_subscription_status('valid')
    valid = valid_consumer_count
    assert_equal 1, valid
  end

  def test_invalid_consumer_count
    @host.subscription_facet.update_subscription_status('invalid')
    invalid = invalid_consumer_count
    assert_equal 1, invalid
  end

  def test_unknown_consumer_count
    @host.subscription_facet.update_subscription_status('unknown')
    unknown = unknown_consumer_count
    assert_equal 1, unknown
  end

  def test_unregistered_consumer_count
    @host.subscription_facet.update!(uuid: nil)
    unknown = unknown_consumer_count
    assert_equal 1, unknown
  end

  def test_unsubscribed_hypervisor_consumer_count
    @host.subscription_facet.update_subscription_status('unsubscribed_hypervisor')
    unknown = unsubscribed_hypervisor_count
    assert_equal 1, unknown
  end

  def test_partial_consumer_count_nil
    partial = partial_consumer_count
    refute partial.nil?
  end

  def test_valid_consumer_count_nil
    valid = valid_consumer_count
    refute valid.nil?
  end

  def test_invalid_consumer_count_nil
    invalid = invalid_consumer_count
    refute invalid.nil?
  end

  def test_unknown_consumer_count_nil
    unknown = unknown_consumer_count
    refute unknown.nil?
  end
end
