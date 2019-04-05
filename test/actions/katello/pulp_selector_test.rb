require 'katello_test_helper'

module ::Actions::Katello
  class Pulp2TestAction < Actions::Pulp::Abstract
  end

  class Pulp3TestAction < Actions::Pulp3::Abstract
  end

  class PulpSelectorTestTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:smart_proxy) { SmartProxy.new }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:content_view_puppet_env) { katello_content_view_puppet_environments(:library_view_puppet_environment) }

    def test_plans_puppet_env
      action = create_action Actions::Katello::PulpSelector

      plan_action(action, [Pulp2TestAction, Pulp3TestAction], content_view_puppet_env, smart_proxy)

      assert_action_planed_with(action, Pulp2TestAction, content_view_puppet_env, smart_proxy)
    end

    def test_plans_pulp2
      smart_proxy.stubs(:pulp3_support?).returns(false)
      action = create_action Actions::Katello::PulpSelector

      plan_action(action, [Pulp2TestAction, Pulp3TestAction], repo, smart_proxy)

      assert_action_planed_with(action, Pulp2TestAction, repo, smart_proxy)
    end

    def test_plans_pulp3
      smart_proxy.stubs(:pulp3_support?).returns(true)
      action = create_action Actions::Katello::PulpSelector

      plan_action(action, [Pulp2TestAction, Pulp3TestAction], repo, smart_proxy)

      assert_action_planed_with(action, Pulp3TestAction, repo, smart_proxy)
    end

    def test_plans_not_found
      smart_proxy.stubs(:pulp3_support?).returns(true)
      action = create_action Actions::Katello::PulpSelector

      assert_raise do
        plan_action(action, [Pulp2TestAction], repo, smart_proxy)
      end
    end
  end
end
