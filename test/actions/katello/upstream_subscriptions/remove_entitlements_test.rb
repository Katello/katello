require 'katello_test_helper'

describe ::Actions::Katello::UpstreamSubscriptions::RemoveEntitlements do
  include Dynflow::Testing

  subject { described_class }

  before :all do
    @org = FactoryBot.build(:katello_organization)
    set_organization(@org)
    @action = create_action(subject)
    @remove_action_class = ::Actions::Katello::UpstreamSubscriptions::RemoveEntitlement
    @manifest_action_class = ::Actions::Katello::Organization::ManifestRefresh
  end

  it 'plans' do
    pool1 = katello_pools(:pool_one)
    pool2 = katello_pools(:pool_two)

    pool1.expects(:upstream_entitlement_id).returns('a').twice
    pool2.expects(:upstream_entitlement_id).returns('b').twice

    ::Katello::Pool.expects(:find).with(pool1.id).returns(pool1)
    ::Katello::Pool.expects(:find).with(pool2.id).returns(pool2)

    plan_action(@action, [pool1.id, pool2.id])

    assert_action_planned_with(@action, @remove_action_class, entitlement_id: 'a')
    assert_action_planned_with(@action, @remove_action_class, entitlement_id: 'b')
    assert_action_planned_with(@action, @manifest_action_class, @org)
  end

  it 'raises an error when the pool has no upstream entitlement' do
    pool1 = katello_pools(:pool_one)
    pool1.expects(:upstream_entitlement_id).returns(nil)
    ::Katello::Pool.expects(:find).with(pool1.id).returns(pool1)

    error = proc { plan_action(@action, [pool1.id]) }.must_raise RuntimeError
    error.message.must_match(/upstream/)
  end

  it 'raises an error when given no pool ids' do
    error = proc { plan_action(@action, []) }.must_raise RuntimeError
    error.message.must_match(/provided/)
  end

  it 'raises an error when no organization is set' do
    set_organization(nil)
    error = proc { plan_action(@action, [:foo]) }.must_raise RuntimeError
    error.message.must_match(/is not set/)
  end
end
