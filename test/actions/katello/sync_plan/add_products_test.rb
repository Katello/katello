require 'katello_test_helper'

describe ::Actions::Katello::SyncPlan::AddProducts do
  include Dynflow::Testing
  include Support::Actions::Fixtures
  include Support::Actions::RemoteAction
  include FactoryGirl::Syntax::Methods

  before :all do
    @product = katello_products(:fedora)
    @sync_plan = FactoryGirl.build(
      'katello_sync_plan',
      :products => [],
      :interval => 'daily',
      :sync_date => Time.now,
      :organization_id => Organization.first.id
    )
  end

  let(:action_class) { ::Actions::Katello::SyncPlan::AddProducts }
  let(:action) { create_action action_class }

  it 'plans' do
    set_user
    action.stubs(:action_subject).with(@sync_plan)
    plan_action(action, @sync_plan, [@product.id])

    assert_action_planed_with(action, ::Actions::Katello::Product::Update, @product, :sync_plan_id => @sync_plan.id)
  end
end
