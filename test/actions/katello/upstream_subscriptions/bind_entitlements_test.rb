require 'katello_test_helper'

describe ::Actions::Katello::UpstreamSubscriptions::BindEntitlements do
  include Dynflow::Testing

  subject { described_class }

  before :all do
    @org = FactoryBot.build(:katello_organization)
    @action = create_action(subject)
    @manifest_action_class = ::Actions::Katello::Organization::ManifestRefresh
  end

  it 'plans' do
    Organization.stubs(:current).returns(@org)

    pools = [{"poolId" => "abcd1234", "quantity" => 3}]

    plan_action(@action, pools)

    pools.each do |pool|
      assert_action_planned_with(@action, ::Actions::Katello::UpstreamSubscriptions::BindEntitlement, pool)
    end

    assert_action_planned_with(@action, @manifest_action_class, @org)
  end

  it 'raises an error when given no pools' do
    error = proc { plan_action(@action, []) }.must_raise RuntimeError
    assert_match(/No pools were provided/, error.message)
  end

  it 'raises an error when organization is set' do
    set_organization(nil)
    error = proc { plan_action(@action, [{}]) }.must_raise RuntimeError
    assert_match(/Current organization is not set/, error.message)
  end
end
