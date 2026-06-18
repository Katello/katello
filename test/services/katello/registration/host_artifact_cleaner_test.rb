require 'katello_test_helper'

module Katello
  module Registration
    class HostArtifactCleanerTest < ActiveSupport::TestCase
      let(:content_facet) do
        FactoryBot.build_stubbed(:katello_content_facet,
                                 :with_content_view_environment,
                                 :with_kickstart_repository,
                                 :with_content_source,
                                 :with_applicable_errata,
                                 :with_bound_repositories)
      end

      let(:host) do
        content_facet.host
      end

      before do
        ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
        host.expects(:installed_packages).returns(mock(delete_all: true))
        host.expects(:rhsm_fact_values).returns(mock(delete_all: true))
        host.expects(:get_status).with(::Katello::ErrataStatus).returns(mock(destroy: true))
        host.expects(:get_status).with(::Katello::TraceStatus).returns(mock(destroy: true))
      end

      test "preserves provisioning data" do
        host.content_facet.expects(:calculate_and_import_applicability)
        host.content_facet.expects(:mark_cvenvs_unchanged)
        content_facet.expects(:save!)

        cleaner = HostArtifactCleaner.new(host: host)
        cleaner.clean!(preserve_for_provisioning: true)

        # Verify provisioning information is maintained
        refute_empty host.content_facet.content_view_environments
        refute_nil host.content_facet.kickstart_repository_id
        refute_equal ::SmartProxy.pulp_primary, host.content_facet.content_source

        # Verify other data is still cleared as expected
        assert_empty host.content_facet.bound_repositories
        assert_empty host.content_facet.applicable_errata
      end

      test "cleans provisioning data" do
        host.content_facet.expects(:calculate_and_import_applicability)
        host.content_facet.expects(:mark_cvenvs_unchanged)
        content_facet.expects(:save!)

        cleaner = HostArtifactCleaner.new(host: host)
        cleaner.clean!

        # Verify provisioning information is cleared
        assert_empty host.content_facet.content_view_environments
        assert_nil host.content_facet.kickstart_repository_id
        assert_equal ::SmartProxy.pulp_primary, host.content_facet.content_source

        # Verify other data is still cleared as expected
        assert_empty host.content_facet.bound_repositories
        assert_empty host.content_facet.applicable_errata
      end

      test "preserves content facet data" do
        host.content_facet.expects(:calculate_and_import_applicability).never
        host.content_facet.expects(:mark_cvenvs_unchanged).never
        content_facet.expects(:save!).never

        cleaner = HostArtifactCleaner.new(host: host)
        cleaner.clean!(clear_content_facet: false)

        refute_empty host.content_facet.bound_repositories
        refute_empty host.content_facet.content_view_environments
        refute_nil host.content_facet.kickstart_repository_id
        refute_equal ::SmartProxy.pulp_primary, host.content_facet.content_source
        refute_empty host.content_facet.applicable_errata
        refute_empty host.content_facet.applicable_errata
      end
    end
  end
end
