module Katello
  module Util
    class FakeHostgroupContentFacet < ApplicationRecord
      self.table_name = 'katello_hostgroup_content_facets'
    end

    class CveHgcfMigrator # used in db/migrate/20260402151630_add_content_view_environment_to_hostgroup_content_facet.rb
      def execute!
        validation_results = validate_hostgroup_facets
        {
          partial_data_count: validation_results[:partial_data_count],
          problematic_facets: validation_results[:problematic_facets],
        }
      end

      private

      def validate_hostgroup_facets
        hostgroups_with_no_cve = []
        hostgroups_with_missing_cve = []
        hostgroups_with_partial_data = []

        FakeHostgroupContentFacet.all.each do |hg_facet|
          next if hg_facet.content_view_id.blank? && hg_facet.lifecycle_environment_id.blank?

          if partial_data?(hg_facet)
            hostgroups_with_partial_data << hg_facet
          else
            categorize_facet(hg_facet, hostgroups_with_no_cve, hostgroups_with_missing_cve)
          end
        end

        {
          partial_data_count: hostgroups_with_partial_data.count,
          problematic_facets: build_problematic_facets_info(hostgroups_with_no_cve + hostgroups_with_missing_cve),
        }
      end

      def partial_data?(hg_facet)
        hg_facet.content_view_id.blank? || hg_facet.lifecycle_environment_id.blank?
      end

      def categorize_facet(hg_facet, hostgroups_with_no_cve, hostgroups_with_missing_cve)
        if valid_cv_and_lce?(hg_facet)
          cve = find_content_view_environment(hg_facet)
          hostgroups_with_no_cve << hg_facet if cve.blank?
        else
          hostgroups_with_missing_cve << hg_facet
        end
      end

      def valid_cv_and_lce?(hg_facet)
        ::Katello::ContentView.exists?(id: hg_facet.content_view_id) &&
          ::Katello::KTEnvironment.exists?(hg_facet.lifecycle_environment_id)
      end

      def find_content_view_environment(hg_facet)
        ::Katello::ContentViewEnvironment.find_by(
          content_view_id: hg_facet.content_view_id,
          environment_id: hg_facet.lifecycle_environment_id
        )
      end

      def build_problematic_facets_info(problematic_facets)
        problematic_facets.map do |hg_facet|
          hostgroup = ::Hostgroup.find_by(id: hg_facet.hostgroup_id)
          {
            content_facet_id: hg_facet.id,
            hostgroup_id: hg_facet.hostgroup_id,
            hostgroup_name: hostgroup&.name || "Unknown",
            content_view_id: hg_facet.content_view_id,
            lifecycle_environment_id: hg_facet.lifecycle_environment_id,
          }
        end
      end
    end
  end
end
