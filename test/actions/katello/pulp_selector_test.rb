require 'katello_test_helper'

module ::Actions::Katello
  class Pulp3TestAction < Actions::Pulp3::Abstract
  end

  class KatelloAction < Actions::EntryAction
    include Actions::Katello::PulpSelector

    def plan_self(*args)
      plan_pulp_action(*args)
    end
  end

  class KatelloOptionalAction < Actions::EntryAction
    include Actions::Katello::PulpSelector

    def plan_self(*args)
      plan_optional_pulp_action(*args)
    end
  end

  class PulpSelectorTestTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Actions::Katello::PulpSelector

    let(:smart_proxy) { SmartProxy.new }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }

    def test_plans_pulp3
      action = create_action KatelloAction

      plan_action(action, [Pulp3TestAction], repo, smart_proxy)

      assert_action_planned_with(action, Pulp3TestAction, repo, smart_proxy)
    end
  end
end
