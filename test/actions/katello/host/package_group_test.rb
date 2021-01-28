require_relative '../agent_action_tests.rb'

module ::Actions::Katello::Host::PackageGroup
  class InstallTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:action_class) { ::Actions::Katello::Host::PackageGroup::Install }
    let(:content) { %w(backup) }
  end

  class RemoveTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:action_class) { ::Actions::Katello::Host::PackageGroup::Remove }
    let(:content) { %w(backup) }
  end
end
