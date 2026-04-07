module Katello
  module Util
    class FakeHostgroupContentFacet < ApplicationRecord
      self.table_name = 'katello_hostgroup_content_facets'
    end

    class CveHgcfMigrator # used in db/migrate/20260402151630_add_content_view_environment_to_hostgroup_content_facet.rb
      def execute!
        hostgroups_with_no_cve = []
        hostgroups_with_missing_cve = []
        hostgroups_with_partial_data = []

        FakeHostgroupContentFacet.all.each do |hg_facet|
          next if hg_facet.content_view_id.blank? && hg_facet.lifecycle_environment_id.blank?

          # If only one of CV or LCE is set, the migration will handle it by using org defaults
          if hg_facet.content_view_id.blank? || hg_facet.lifecycle_environment_id.blank?
            hostgroups_with_partial_data << hg_facet
            next
          end

          # Both CV and LCE are set, validate they form a valid CVE
          if ::Katello::ContentView.exists?(id: hg_facet.content_view_id) && ::Katello::KTEnvironment.exists?(hg_facet.lifecycle_environment_id)
            cve = ::Katello::ContentViewEnvironment.find_by(content_view_id: hg_facet.content_view_id, environment_id: hg_facet.lifecycle_environment_id)
            if cve.blank?
              hostgroups_with_no_cve << hg_facet
            end
          else
            hostgroups_with_missing_cve << hg_facet
          end
        end

        if hostgroups_with_partial_data.any?
          Rails.logger.info "Found #{hostgroups_with_partial_data.count} hostgroup content facets with only CV or LCE set. These will be migrated using organization defaults."
        end

        # Only fail for hostgroups that have both CV and LCE set but don't form a valid CVE
        problematic_facets = hostgroups_with_no_cve + hostgroups_with_missing_cve
        if problematic_facets.any?
          failed_rows = []
          problematic_facets.each do |hg_facet|
            hostgroup = ::Hostgroup.find_by(id: hg_facet.hostgroup_id)
            failed_rows << {
              content_facet_id: hg_facet.id,
              hostgroup_id: hg_facet.hostgroup_id,
              hostgroup_name: hostgroup&.name || "Unknown",
              content_view_id: hg_facet.content_view_id,
              lifecycle_environment_id: hg_facet.lifecycle_environment_id,
            }
          end

          error_message = "Cannot complete migration: #{failed_rows.count} hostgroup content facets have " \
                          "content_view_id/lifecycle_environment_id combinations that don't match any " \
                          "ContentViewEnvironment record. Make sure the content view is published and " \
                          "promoted before reassigning. Failed rows: #{failed_rows.inspect}"
          Rails.logger.error error_message
          fail ActiveRecord::IrreversibleMigration, error_message
        end

        Rails.logger.info "Hostgroup content facet migration validation passed"
      end
    end
  end
end
