require 'katello_test_helper'

describe ::Actions::Katello::UpstreamSubscriptions::RemoveEntitlement do
  include Dynflow::Testing

  subject { described_class }

  before :all do
    @org = FactoryBot.create(:katello_organization)
    set_organization(@org)
    @planned_action = create_and_plan_action(subject, org_id: @org.id, entitlement_id: 'foo', sub_name: 'Test Sub')
  end

  it 'runs' do
    ::Katello::Resources::Candlepin::UpstreamConsumer.expects(:remove_entitlement).with('foo')
    run_action @planned_action
  end

  it 'outputs a message if entitlement is gone' do
    ::Katello::Resources::Candlepin::UpstreamConsumer.expects(:remove_entitlement).with('foo').raises(::Katello::Errors::UpstreamEntitlementGone)
    assert_equal("Test Sub has already been deleted", run_action(@planned_action).output[:response])
  end
end
