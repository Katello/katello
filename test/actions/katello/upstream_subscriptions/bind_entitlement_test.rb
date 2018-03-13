require 'katello_test_helper'

describe ::Actions::Katello::UpstreamSubscriptions::BindEntitlement do
  include Dynflow::Testing

  subject { described_class }

  before do
    @org = FactoryBot.build(:katello_organization)
    Organization.stubs(:current).returns(@org)
    @pool = {pool: "abcd1234", quantity: 3}
    @action = create_and_plan_action(subject, @pool)
    Organization.unscoped.class.any_instance.expects(:find).with(@org.id).returns(@org)
  end

  it 'runs' do
    ::Katello::Resources::Candlepin::UpstreamConsumer.expects(:bind_entitlement).with(@pool)

    @action = run_action(@action)
  end
end
