require 'katello_test_helper'

class Actions::Candlepin::ActivationKey::CreateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe 'Create' do
    let(:action_class) { ::Actions::Candlepin::ActivationKey::Create }
    let(:planned_action) do
      create_and_plan_action(action_class,
                             organization_label: nil,
                             auto_attach: true,
                             service_level: 'Self-Support',
                             release_version: '7Server',
                             purpose_role: "role",
                             purpose_usage: "usage"
                            )
    end

    it 'runs' do
      ::Katello::Util::Model.stubs(:uuid).returns(123)
      ::Katello::Resources::Candlepin::ActivationKey.expects(:create).with(123, nil, true, "Self-Support", "7Server", "role", "usage")
      run_action planned_action
    end
  end
end

class Actions::Candlepin::ActivationKey::UpdateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe 'Update' do
    let(:action_class) { ::Actions::Candlepin::ActivationKey::Update }

    let(:planned_action) do
      create_and_plan_action(action_class, cp_id: "foo", :release_version => 1, :service_level => "Premium", :auto_attach => true, :purpose_role => "test role", :purpose_usage => "test usage")
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::ActivationKey.expects(:update).with("foo", 1, "Premium", true, "test role", "test usage")
      run_action planned_action
    end
  end
end

class Actions::Candlepin::ActivationKey::DestroyTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe "Destroy" do
    let(:action_class) { ::Actions::Candlepin::ActivationKey::Destroy }
    let(:cp_id) { "foo_boo" }
    let(:planned_action) do
      create_and_plan_action(action_class, cp_id: cp_id)
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::ActivationKey.expects(:destroy).with(cp_id)
      run_action planned_action
    end
  end
end
