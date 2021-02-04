require_relative '../agent_action_tests.rb'

module ::Actions::Katello::Host::Package
  class InstallTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:content) { %w(vim vi) }
    let(:action_class) { ::Actions::Katello::Host::Package::Install }
  end

  class RemoveTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:content) { %w(vim vi) }
    let(:action_class) { ::Actions::Katello::Host::Package::Remove }
  end

  class UpdateTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:content) { %w(vim vi) }
    let(:action_class) { ::Actions::Katello::Host::Package::Update }
  end
end
