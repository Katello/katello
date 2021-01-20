require_relative '../agent_action_tests.rb'

module ::Actions::Katello::Host::Package
  class InstallTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:packages) { %w(vim vi) }
    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :hostname => host.name, :packages => packages)
      plan_action action, host, packages
    end

    let(:action_class) { ::Actions::Katello::Host::Package::Install }

    let(:dispatcher_method) { :install_package }
    let(:dispatcher_params) do
      {
        host_id: host.id,
        packages: packages
      }
    end
  end

  class RemoveTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:packages) { %w(vim vi) }
    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :hostname => host.name, :packages => packages)
      plan_action action, host, packages
    end

    let(:action_class) { ::Actions::Katello::Host::Package::Remove }

    let(:dispatcher_method) { :remove_package }
    let(:dispatcher_params) do
      {
        host_id: host.id,
        packages: packages
      }
    end
  end

  class UpdateTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:packages) { %w(vim vi) }
    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :hostname => host.name, :packages => packages)
      plan_action action, host, packages
    end

    let(:action_class) { ::Actions::Katello::Host::Package::Update }

    let(:dispatcher_method) { :update_package }
    let(:dispatcher_params) do
      {
        host_id: host.id,
        packages: packages
      }
    end
  end
end
