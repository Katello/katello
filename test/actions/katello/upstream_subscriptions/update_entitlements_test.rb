require 'katello_test_helper'

describe ::Actions::Katello::UpstreamSubscriptions::UpdateEntitlements do
  include Dynflow::Testing

  subject { described_class }

  before :all do
    @org = FactoryBot.build(:katello_organization)
    set_organization(@org)
    @action = create_action(subject)
    @update_action_class = ::Actions::Katello::UpstreamSubscriptions::UpdateEntitlement
    @manifest_action_class = ::Actions::Katello::Organization::ManifestRefresh
  end

  it 'plans' do
    pool = katello_pools(:pool_one)
    pool.expects(:upstream_entitlement_id).returns(:foo).twice
    ::Katello::Pool.expects(:find).with(pool.id).returns(pool)
    pools = [{id: pool.id, quantity: 5}]

    plan_action(@action, pools)

    assert_action_planned_with(@action, @update_action_class, entitlement_id: :foo, quantity: 5)
    assert_action_planned_with(@action, @manifest_action_class, @org)
  end

  it 'raises an error when given no pools' do
    error = proc { plan_action(@action, []) }.must_raise RuntimeError
    assert_match(/provided/, error.message)
  end

  it 'raises an error when the pool has no upstream entitlement' do
    pool1 = katello_pools(:pool_one)
    pool1.expects(:upstream_entitlement_id).returns(nil)
    ::Katello::Pool.expects(:find).with(pool1.id).returns(pool1)

    error = proc { plan_action(@action, [{id: pool1.id, quantity: 1}]) }.must_raise RuntimeError
    assert_match(/upstream/, error.message)
  end

  it 'raises an error when no organization is set' do
    set_organization(nil)
    error = proc { plan_action(@action, [:foo]) }.must_raise RuntimeError
    assert_match(/is not set/, error.message)
  end
end
