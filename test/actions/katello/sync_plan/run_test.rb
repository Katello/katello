require 'katello_test_helper'

describe ::Actions::Katello::SyncPlan::Run do
  include Dynflow::Testing
  include Support::Actions::Fixtures
  include FactoryBot::Syntax::Methods

  before :all do
    @sync_plan = katello_sync_plans(:sync_plan_hourly)
  end

  let(:action_class) { ::Actions::Katello::SyncPlan::Run }
  let(:action) { create_action action_class }
  let(:uuid) { SecureRandom.uuid }
  let(:task) do
    OpenStruct.new(:id => uuid).tap do |o|
      o.stubs(:add_missing_task_groups)
      o.stubs(:task_groups).returns([])
    end
  end

  it 'plans' do
    ForemanTasks::Task::DynflowTask.stubs(:where).returns(mock.tap { |m| m.stubs(:first! => task) })
    products = katello_products(:fedora, :redhat)
    @sync_plan.products << products
    action.stubs(:action_subject).with(@sync_plan)
    plan_action(action, @sync_plan)
    syncable_products = @sync_plan.products.syncable
    syncable_repositories = ::Katello::RootRepository.where(:product_id => syncable_products).has_url
    assert_action_planned_with(action, ::Actions::BulkAction, ::Actions::Katello::Repository::Sync, syncable_repositories.map(&:library_instance),
                              generate_applicability: false)
  end

  it 'does not plan without products' do
    ForemanTasks::Task::DynflowTask.stubs(:where).returns(mock.tap { |m| m.stubs(:first! => task) })
    action.stubs(:action_subject).with(@sync_plan)
    plan_action(action, @sync_plan)
    syncable_products = @sync_plan.products.syncable
    syncable_repositories = ::Katello::RootRepository.where(:product_id => syncable_products).has_url
    assert_empty syncable_products
    assert_empty syncable_repositories
    refute_action_planed action, ::Actions::BulkAction
  end
end
