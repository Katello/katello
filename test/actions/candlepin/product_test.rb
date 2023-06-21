require 'katello_test_helper'

class Actions::Candlepin::Product::ContentUpdateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe 'Create' do
    let(:action_class) { ::Actions::Candlepin::Product::Create }
    let(:planned_action) do
      create_and_plan_action action_class, :id => 4, :name => 'foo', :owner => 'default_org', :multiplier => nil, :attributes => {}
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Product.expects(:create).with('default_org', :name => 'foo', :id => 4,
                                                                     :multiplier => nil, :attributes => {})
      run_action planned_action
    end
  end

  describe 'ContentUpdate' do
    let(:action_class) { ::Actions::Candlepin::Product::ContentUpdate }
    let(:planned_action) do
      create_and_plan_action action_class, id: 123
    end

    it 'finalizes' do
      repo = katello_repositories(:fedora_17_x86_64)
      ::Katello::Repository.expects(:find).returns(repo)
      ::Katello::Resources::Candlepin::Content.expects(:update)
      finalize_action planned_action
    end
  end
end

class Actions::Candlepin::Product::UpdateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  describe 'Update' do
    let(:action_class) { ::Actions::Candlepin::Product::Update }
    let(:planned_action) do
      create_and_plan_action action_class, owner: 'Default_Organization', name: 'Animal Product', id: 123
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Product.expects(:update).with('Default_Organization', :name => 'Animal Product', :id => 123)
      run_action planned_action
    end
  end
end

class Actions::Candlepin::Product::DestroyTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe "Delete Pools" do
    let(:action_class) { ::Actions::Candlepin::Product::DeletePools }
    let(:label) { "foo" }
    let(:cp_id) { "foo_boo" }
    let(:pool_id) { "100" }
    let(:pools) { [{"id" => pool_id, "cp_id" => pool_id}] }

    let(:planned_action) do
      create_and_plan_action(action_class,
                             organization_label: label,
                             cp_id: cp_id)
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Pool.expects(:destroy).with(pool_id)
      ::Katello::Resources::Candlepin::Product.expects(:pools).with(label, cp_id).returns(pools)
      run_action planned_action
    end
  end

  describe "Delete Subscriptions" do
    let(:action_class) { ::Actions::Candlepin::Product::DeleteSubscriptions }
    let(:label) { "foo" }
    let(:cp_id) { "foo_boo" }
    let(:planned_action) do
      create_and_plan_action(action_class,
                             organization_label: label,
                             cp_id: cp_id)
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Product.expects(:delete_subscriptions).with(label, cp_id)
      run_action planned_action
    end
  end

  describe "Destroy" do
    let(:action_class) { ::Actions::Candlepin::Product::Destroy }
    let(:cp_id) { "foo_boo" }
    let(:planned_action) do
      create_and_plan_action(action_class,
                             cp_id: cp_id,
                             owner: 'whoops')
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Product.expects(:destroy).with('whoops', cp_id)
      run_action planned_action
    end
  end
end
