require 'katello_test_helper'

describe ::Actions::Katello::SyncPlan::RemoveProducts do
  include Dynflow::Testing
  include Support::Actions::Fixtures
  include FactoryGirl::Syntax::Methods

  before :all do
    @product = katello_products(:fedora)
    @sync_plan = FactoryGirl.build(
      'katello_sync_plan',
      :products => [@product],
      :interval => 'daily',
      :sync_date => Time.now,
      :organization_id => Organization.first.id
    )
  end

  let(:action_class) { ::Actions::Katello::SyncPlan::RemoveProducts }
  let(:action) { create_action action_class }

  it 'plans' do
    set_user
    action.stubs(:action_subject).with(@sync_plan)
    plan_action(action, @sync_plan, [@product.id])

    assert_action_planed_with(action, ::Actions::Katello::Product::Update, @product, :sync_plan_id => nil)
  end
end
