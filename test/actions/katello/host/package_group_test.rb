require_relative '../agent_action_tests.rb'

module ::Actions::Katello::Host::PackageGroup
  class InstallTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:action_class) { ::Actions::Katello::Host::PackageGroup::Install }
    let(:package_groups) { %w(backup) }

    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :groups => package_groups)
      plan_action action, host, package_groups
    end

    let(:dispatcher_method) { :install_package_group }
    let(:dispatcher_params) do
      {
        host_id: host.id,
        groups: package_groups
      }
    end
  end

  class RemoveTest < ActiveSupport::TestCase
    include Actions::Katello::AgentActionTests

    let(:action_class) { ::Actions::Katello::Host::PackageGroup::Remove }
    let(:package_groups) { %w(backup) }
    let(:dispatcher_method) { :remove_package_group }

    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :groups => package_groups)
      plan_action action, host, package_groups
    end

    let(:dispatcher_params) do
      {
        host_id: host.id,
        groups: package_groups
      }
    end
  end
end
