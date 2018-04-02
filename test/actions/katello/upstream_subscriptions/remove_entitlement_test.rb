require 'katello_test_helper'

describe ::Actions::Katello::UpstreamSubscriptions::RemoveEntitlement do
  include Dynflow::Testing

  subject { described_class }

  before :all do
    @org = FactoryBot.create(:katello_organization)
    set_organization(@org)
    @planned_action = create_and_plan_action(subject, org_id: @org.id, entitlement_id: 'foo')
  end

  it 'runs' do
    ::Katello::Resources::Candlepin::UpstreamConsumer.expects(:remove_entitlement).with('foo')
    run_action @planned_action
  end
end
