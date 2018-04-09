require 'katello_test_helper'

describe ::Actions::Katello::UpstreamSubscriptions::UpdateEntitlement do
  include Dynflow::Testing

  subject { described_class }

  before :all do
    @org = get_organization
    @planned_action = create_and_plan_action(subject, entitlement_id: 'foo', quantity: 5)
  end

  it 'runs' do
    ::Katello::Resources::Candlepin::UpstreamEntitlement.expects(:update).with('foo', 5)
    run_action @planned_action
  end
end
