require 'test_helper'
require 'katello_test_helper'

class DashboardHelperTest < ActiveSupport::TestCase
  include ApplicationHelper
  include ::Katello::Concerns::DashboardHelperExtensions

  def setup
    User.current = User.anonymous_api_admin
    @library = katello_environments(:library)
    @host =  FactoryGirl.build(:host, :with_content, :with_subscription,
                               :content_view => katello_content_views(:library_dev_view),
                               :lifecycle_environment => katello_environments(:library), :id => 101)
    @host.organization = taxonomies(:organization1)
    @host.save!
    Organization.current = @host.organization
  end

  def test_total_host_count
    total = total_host_count
    assert !total.nil?
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

  def test_partial_consumer_count_nil
    partial = partial_consumer_count
    assert !partial.nil?
  end

  def test_valid_consumer_count_nil
    valid = valid_consumer_count
    assert !valid.nil?
  end

  def test_invalid_consumer_count_nil
    invalid = invalid_consumer_count
    assert !invalid.nil?
  end

  def test_unknown_consumer_count_nil
    unknown = unknown_consumer_count
    assert !unknown.nil?
  end
end
