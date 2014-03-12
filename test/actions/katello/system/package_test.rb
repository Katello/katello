#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module ::Actions::Katello::System::Package

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:system) { mock('a_system', uuid: 'uuid').mimic!(::Katello::System) }
    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(system, :packages => packages = %w(vim vi))
      plan_action action, system, packages
    end
  end

  class InstallTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Package::Install }
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
        let(:fixture_variant) {  :success }

        specify do
          action.humanized_output.must_equal <<-OUTPUT.chomp
1:emacs-23.1-21.el6_2.3.x86_64
libXmu-1.1.1-2.el6.x86_64
libXaw-1.0.11-2.el6.x86_64
libotf-0.9.9-3.1.el6.x86_64
            OUTPUT
        end
      end

      describe 'no packages installed' do
        let(:fixture_variant) {  :no_packages }

        specify do
          action.humanized_output.must_equal "No new packages installed"
        end
      end

      describe 'with error' do
        let(:fixture_variant) {  :error }

        specify do
          action.humanized_output.must_equal <<-MSG.chomp
No new packages installed
emacss: No package(s) available to install
            MSG
        end
      end
    end

    class RemoveTest < TestBase
      let(:action_class) { ::Actions::Katello::System::Package::Remove }
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
          let(:fixture_variant) {  :success }

          specify do
            action.humanized_output.must_equal <<-OUTPUT.chomp
libXmu-1.1.1-2.el6.x86_64
1:emacs-23.1-21.el6_2.3.x86_64
libXaw-1.0.11-2.el6.x86_64
libotf-0.9.9-3.1.el6.x86_64
            OUTPUT
          end
        end

        describe 'no packages uninstalled' do
          let(:fixture_variant) {  :no_packages }

          specify do
            action.humanized_output.must_equal "No packages removed"
          end
        end
      end
    end
  end
end
