require 'katello_test_helper'

describe ::Actions::Katello::SyncPlan::Destroy do
  include Dynflow::Testing
  include Support::Actions::Fixtures
  include FactoryBot::Syntax::Methods

  before :all do
    @product = FactoryBot.build('katello_product', provider: @provider, cp_id: 1234)
    @sync_plan = FactoryBot.build('katello_sync_plan', :products => [@product])
  end

  let(:action_class) { ::Actions::Katello::SyncPlan::Destroy }
  let(:action) { create_action action_class }

  it 'plans' do
    action.stubs(:action_subject).with(@sync_plan)
    action.expects(:plan_self)

    plan_action(action, @sync_plan)

    assert_action_planed_with(action, ::Actions::Katello::Product::Update, @product, :sync_plan_id => nil)
  end
end
