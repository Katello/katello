require 'katello_test_helper'

class Actions::Candlepin::Consumer::CreateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe 'Create' do
    let(:action_class) { ::Actions::Candlepin::Consumer::Create }
    let(:planned_action) do
      create_and_plan_action action_class, cp_environment_id: 123
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Consumer.expects(:create).returns({})
      run_action planned_action
    end
  end
end
