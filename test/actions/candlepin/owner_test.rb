require 'katello_test_helper'

module ::Actions::Candlepin::Owner
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction

    before do
      stub_remote_user
    end

    let(:label) { "foo" }
    let(:owner_name) { "boo" }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Candlepin::Owner::Create }
    let(:planned_action) do
      create_and_plan_action action_class, label: label, name: owner_name
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Owner.expects(:create).with(label, owner_name)
      run_action planned_action
    end
  end
end
