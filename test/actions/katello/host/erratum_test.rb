require_relative '../agent_action_tests.rb'

module ::Actions::Katello::Host::Erratum
  class InstallTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:action_class) { ::Actions::Katello::Host::Erratum::Install }

    let(:errata) { %w(RHBA-2014-1234) }

    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :hostname => host.name, :errata => errata)
      plan_action action, host, errata
    end

    let(:dispatcher_method) { :install_errata }

    let(:dispatcher_params) do
      {
        host_id: host.id,
        errata_ids: errata
      }
    end
  end
end
