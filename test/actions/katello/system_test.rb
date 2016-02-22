require 'katello_test_helper'
require 'support/host_support'

module ::Actions::Katello::System
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }

    before do
      set_user
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Destroy }

    let(:system) { Katello::System.find(katello_systems(:simple_server)) }

    it 'plans' do
      stub_remote_user
      action.stubs(:action_subject).with(system)
      system.foreman_host = ::Host.new

      plan_action(action, system)

      assert_action_planed_with(action, ::Actions::Katello::Host::Destroy, system.foreman_host, {})
    end
  end
end
