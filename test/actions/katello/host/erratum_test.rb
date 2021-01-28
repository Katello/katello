require_relative '../agent_action_tests.rb'

module ::Actions::Katello::Host::Erratum
  class InstallTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:action_class) { ::Actions::Katello::Host::Erratum::Install }
    let(:content) { %w(RHBA-2014-1234) }
  end
end
