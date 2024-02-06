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
end
