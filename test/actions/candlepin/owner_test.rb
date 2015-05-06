require 'katello_test_helper'

module ::Actions::Candlepin::Owner
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction

    before do
      stub_remote_user
    end

    let(:label) { "foo" }
    let(:name) { "boo" }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Candlepin::Owner::Create }
    let(:planned_action) do
      create_and_plan_action action_class, label: label, name: name
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Owner.expects(:create).with(label, name)
      run_action planned_action
    end
  end

  class AutoAttachTest < TestBase
    let(:action_class) { ::Actions::Candlepin::Owner::AutoAttach }
    let(:planned_action) do
      create_and_plan_action action_class, label: label
    end

    it 'runs' do
      action_class.any_instance.expects(:done?).returns(true)
      ::Katello::Resources::Candlepin::Owner.expects(:auto_attach).with(label)
      run_action planned_action
    end
  end
end
