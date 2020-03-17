require 'katello_test_helper'

module ::Actions::Katello::Host::Erratum
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    class Installtest < TestBase
      let(:action_class) { ::Actions::Katello::Host::Erratum::ApplicableErrataInstall }

      let(:uuid) { 'uuid' }
      let(:content_facet) { katello_content_facets(:content_facet_one) }
      let(:host) do
        host_mock = mock('a_host', content_facet: content_facet).mimic!(::Host::Managed)
        host_mock.stubs('name').returns('foobar')
        host_mock
      end
      let(:errata_ids) { %w(RHBA-2014-1234 RHBA-2014-1235 RHBA-2014-1236 RHBA-2014-1237) }
      let(:applicable_errata_list) { [katello_errata(:bugfix), katello_errata(:security)] }

      describe 'with applicable errata' do
        it 'does not plan an install action' do
          applicable_errata = mock('applicable_errata')
          applicable_errata.stubs(:with_identifiers).returns(applicable_errata_list)
          content_facet.stubs(:applicable_errata).returns(applicable_errata)

          action = create_action action_class
          plan_action action, host, :errata_ids => errata_ids

          assert_action_planned_with action, Actions::Katello::Host::Erratum::Install,
            host, applicable_errata_list.pluck(:errata_id)
        end
      end

      describe 'with no applicable errata' do
        let(:errata_ids) { [] }

        it 'does not plan an install action' do
          applicable_errata = mock('applicable_errata')
          applicable_errata.stubs(:with_identifiers).returns([])
          content_facet.stubs(:applicable_errata).returns(applicable_errata)

          action = create_action action_class
          plan_action action, host, :errata_ids => errata_ids

          refute_action_planned action, Actions::Katello::Host::Erratum::Install
        end
      end
    end
  end
end
