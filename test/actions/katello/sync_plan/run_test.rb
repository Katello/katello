require 'katello_test_helper'

describe ::Actions::Katello::SyncPlan::Run do
  include Dynflow::Testing
  include Support::Actions::Fixtures
  include FactoryBot::Syntax::Methods

  before :all do
    @sync_plan = katello_sync_plans(:sync_plan_hourly)
    @products = katello_products(:fedora, :redhat, :empty_product)
    @sync_plan.products << @products
  end

  let(:action_class) { ::Actions::Katello::SyncPlan::Run }
  let(:action) { create_action action_class }

  it 'plans' do
    action.stubs(:action_subject).with(@sync_plan)
    plan_action(action, @sync_plan)
    syncable_products = @sync_plan.products.syncable
    syncable_repositories = ::Katello::Repository.where(:product_id => syncable_products).has_url
    assert_action_planed_with(action, ::Actions::BulkAction, ::Actions::Katello::Repository::Sync, syncable_repositories)
  end
end
