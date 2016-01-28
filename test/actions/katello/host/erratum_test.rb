require 'katello_test_helper'

module ::Actions::Katello::Host::Erratum
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:content_facet) { mock('a_system', uuid: 'uuid').mimic!(::Katello::Host::ContentFacet) }
    let(:host) { mock('a_host', content_facet: content_facet).mimic!(::Host::Managed) }
    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(host, :errata => errata = %w(RHBA-2014-1234))
      plan_action action, host, errata
    end
  end

  class InstallTest < TestBase
    let(:action_class) { ::Actions::Katello::Host::Erratum::Install }
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

      describe 'no errata installed' do
        let(:fixture_variant) {  :no_packages }

        specify do
          action.humanized_output.must_equal "No new packages installed"
        end
      end
    end
  end
end
