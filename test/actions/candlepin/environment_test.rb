require 'katello_test_helper'

module Actions::Candlepin::Environment
  class DestroyTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction

    def setup
      stub_remote_user
    end

    let(:action_class) { ::Actions::Candlepin::Environment::Destroy }

    let(:planned_action) do
      create_and_plan_action(action_class,
                             cp_id: '1234')
    end

    def test_run
      ::Katello::Resources::Candlepin::Environment.expects(:destroy).with('1234')
      run_action planned_action
    end

    def test_run_environment_gone
      ::Katello::Resources::Candlepin::Environment.expects(:destroy).with('1234').raises(Katello::Errors::CandlepinEnvironmentGone)
      run_action planned_action
    end
  end
end
