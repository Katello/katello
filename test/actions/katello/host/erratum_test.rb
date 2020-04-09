require 'katello_test_helper'

module ::Actions::Katello::Host::Erratum
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:uuid) { 'uuid' }
    let(:content_facet) { mock('a_system', uuid: uuid).mimic!(::Katello::Host::ContentFacet) }
    let(:host) do
      host_mock = mock('a_host', content_facet: content_facet, id: 42).mimic!(::Host::Managed)
      host_mock.stubs('name').returns('foobar')
      host_mock
    end
    let(:errata_ids) { %w(RHBA-2014-1234 RHBA-2014-1235 RHBA-2014-1236 RHBA-2014-1237) }
    let(:action) do
      action = create_action action_class
      action.expects(:plan_self)
      action.stubs(:action_subject).with(host, :hostname => host.name, :errata => errata = %w(RHBA-2014-1234))
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
        let(:fixture_variant) { :success }

        specify do
          assert_equal action.humanized_output, <<~OUTPUT.chomp
            1:emacs-23.1-21.el6_2.3.x86_64
            libXaw-1.0.11-2.el6.x86_64
            libXmu-1.1.1-2.el6.x86_64
            libotf-0.9.9-3.1.el6.x86_64
          OUTPUT
        end
      end

      describe 'no errata installed' do
        let(:fixture_variant) { :no_packages }

        specify do
          assert_equal 'No new packages installed', action.humanized_output
        end
      end
    end

    it 'plans installs with batching' do
      Setting.stubs(:[]).returns(2)
      action.stubs(:action_subject).with(host, :hostname => host.name, :errata => errata_ids)
      host.stubs(:id).returns(42)
      host.stubs(:content_facet).returns(content_facet)
      content_facet.stubs(:uuid).returns(uuid)
      action.expects(:plan_self)
      plan_action action, host, errata_ids

      errata_ids.each_slice(Setting['erratum_install_batch_size']) do |errata_ids_batch|
        assert_action_planned_with(action, pulp_action_class, consumer_uuid: content_facet.uuid,
                                   type: 'erratum', args: errata_ids_batch)
      end
    end
  end
end
