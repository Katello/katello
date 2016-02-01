require 'katello_test_helper'

module ::Actions::Katello::Host::PackageGroup
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:content_facet) { mock('a_system', uuid: 'uuid').mimic!(::Katello::Host::ContentFacet) }
    let(:host) { mock('a_host', content_facet: content_facet).mimic!(::Host::Managed) }

    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :groups => package_groups = %w(backup))
      plan_action action, host, package_groups
    end
  end

  class InstallTest < TestBase
    let(:action_class) { ::Actions::Katello::Host::PackageGroup::Install }
    let(:pulp_action_class) { ::Actions::Pulp::Consumer::ContentInstall }

    specify { assert_action_planed action, pulp_action_class }

    describe '#humanized_output' do
      let :action do
        create_action(action_class).tap do |action|
          action.stubs(planned_actions: [pulp_action])
        end
      end
      let(:pulp_action) { fixture_action(pulp_action_class, output: fixture_variant) }

      describe 'successfully installed' do
        let(:fixture_variant) { :package_group_success }

        specify do
          action.humanized_output.must_equal <<-OUTPUT.chomp
amanda-client-2.6.1p2-8.el6.x86_64
amanda-2.6.1p2-8.el6.x86_64
            OUTPUT
        end
      end

      describe 'no packages installed' do
        let(:fixture_variant) { :package_group_no_packages }

        specify do
          action.humanized_output.must_equal "No new packages installed"
        end
      end

      describe 'with error' do
        let(:fixture_variant) { :error }

        specify do
          action.humanized_output.must_equal <<-MSG.chomp
No new packages installed
emacss: No package(s) available to install
            MSG
        end
      end
    end

    class RemoveTest < TestBase
      let(:action_class) { ::Actions::Katello::Host::PackageGroup::Remove }
      let(:pulp_action_class) { ::Actions::Pulp::Consumer::ContentUninstall }

      specify { assert_action_planed action, pulp_action_class }

      describe '#humanized_output' do
        let :action do
          create_action_presentation(action_class).tap do |action|
            action.stubs(planned_actions: [pulp_action])
          end
        end
        let(:pulp_action) { fixture_action(pulp_action_class, output: fixture_variant) }

        describe 'successfully uninstalled' do
          let(:fixture_variant) { :package_group_success }

          specify do
            action.humanized_output.must_equal <<-OUTPUT.chomp
amanda-client-2.6.1p2-8.el6.x86_64
amanda-2.6.1p2-8.el6.x86_64
            OUTPUT
          end
        end

        describe 'no packages uninstalled' do
          let(:fixture_variant) { :package_group_no_packages }

          specify do
            action.humanized_output.must_equal "No packages removed"
          end
        end
      end
    end
  end
end
