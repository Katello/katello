class AddContentViewEnvironmentToHostgroupContentFacet < ActiveRecord::Migration[6.1]
  class FakeHostgroupContentFacet < ApplicationRecord
    self.table_name = 'katello_hostgroup_content_facets'
  end

  def up
    add_reference :katello_hostgroup_content_facets, :content_view_environment,
                  foreign_key: { to_table: 'katello_content_view_environments' },
                  index: { name: 'index_katello_hg_content_facets_on_cv_env_id' }

    ::Katello::Util::CveHgcfMigrator.new.execute!

    migrate_hostgroup_facets

    remove_column :katello_hostgroup_content_facets, :content_view_id
    remove_column :katello_hostgroup_content_facets, :lifecycle_environment_id
  end

  def down
    add_column :katello_hostgroup_content_facets, :content_view_id, :integer
    add_column :katello_hostgroup_content_facets, :lifecycle_environment_id, :integer

    add_foreign_key :katello_hostgroup_content_facets, :katello_content_views,
                    name: "katello_hostgroup_content_facets_cv_id",
                    column: "content_view_id"

    add_foreign_key :katello_hostgroup_content_facets, :katello_environments,
                    name: "katello_hostgroup_content_facets_lce_id",
                    column: "lifecycle_environment_id"

    ::Katello::Hostgroup::ContentFacet.reset_column_information

    ::Katello::Hostgroup::ContentFacet.find_each do |hostgroup_facet|
      next unless hostgroup_facet.content_view_environment_id

      cve = ::Katello::ContentViewEnvironment.find_by(id: hostgroup_facet.content_view_environment_id)
      if cve
        # Use update_columns to bypass model validations and virtual setters
        hostgroup_facet.update_columns(
          content_view_id: cve.content_view_id,
          lifecycle_environment_id: cve.environment_id
        )
      end
    end

    remove_column :katello_hostgroup_content_facets, :content_view_environment_id
  end

  private

  def migrate_hostgroup_facets
    failed_migrations = []
    total_count = 0
    success_count = 0

    FakeHostgroupContentFacet.find_each do |hostgroup_facet|
      next if hostgroup_facet.lifecycle_environment_id.blank? && hostgroup_facet.content_view_id.blank?

      total_count += 1
      result = migrate_single_facet(hostgroup_facet)

      if result[:success]
        success_count += 1
      else
        failed_migrations << result[:error_info]
      end
    end

    handle_migration_results(failed_migrations, total_count, success_count)
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def migrate_single_facet(hostgroup_facet)
    cv_id = hostgroup_facet.content_view_id
    lce_id = hostgroup_facet.lifecycle_environment_id
    hostgroup = ::Hostgroup.find_by(id: hostgroup_facet.hostgroup_id)

    # If only one of CV or LCE is set, use default values from organization
    if cv_id.blank? || lce_id.blank?
      result = fill_missing_cv_or_lce(hostgroup_facet, cv_id, lce_id, hostgroup)
      return result unless result[:success]

      cv_id = result[:cv_id]
      lce_id = result[:lce_id]
    end

    # Find the ContentViewEnvironment and update
    cv_env_id = find_cv_env_id(cv_id, lce_id)
    if cv_env_id.present? && hostgroup_facet.update_column(:content_view_environment_id, cv_env_id)
      { success: true }
    else
      {
        success: false,
        error_info: build_error_info(hostgroup_facet, hostgroup, cv_id, lce_id, cv_env_id),
      }
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def fill_missing_cv_or_lce(hostgroup_facet, cv_id, lce_id, hostgroup)
    org = find_organization(cv_id, lce_id)

    if org
      Rails.logger.info "Hostgroup content facet #{hostgroup_facet.id} has only one of CV/LCE set, using organization defaults"
      cv_id = org.default_content_view&.id if cv_id.blank?
      lce_id = org.library&.id if lce_id.blank?
      { success: true, cv_id: cv_id, lce_id: lce_id }
    else
      {
        success: false,
        error_info: build_error_info(hostgroup_facet, hostgroup, cv_id, lce_id, nil,
                                      "Could not find organization for hostgroup"),
      }
    end
  end

  def find_organization(cv_id, lce_id)
    if lce_id.present?
      ::Katello::KTEnvironment.find_by(id: lce_id)&.organization
    elsif cv_id.present?
      ::Katello::ContentView.find_by(id: cv_id)&.organization
    end
  end

  def find_cv_env_id(cv_id, lce_id)
    ::Katello::KTEnvironment.find_by(id: lce_id)
                             &.content_view_environments
                             &.find_by(content_view_id: cv_id)
                             &.id
  end

  def build_error_info(hostgroup_facet, hostgroup, cv_id, lce_id, cv_env_id, custom_reason = nil)
    {
      content_facet_id: hostgroup_facet.id,
      hostgroup_id: hostgroup_facet.hostgroup_id,
      hostgroup_name: hostgroup&.name || "Unknown",
      content_view_id: cv_id,
      lifecycle_environment_id: lce_id,
      reason: custom_reason || (cv_env_id.present? ? "Update failed" : "ContentViewEnvironment not found"),
    }
  end

  def handle_migration_results(failed_migrations, total_count, _success_count)
    return unless failed_migrations.any?

    error_message = build_error_message(failed_migrations, total_count)
    Rails.logger.error error_message
    fail ActiveRecord::IrreversibleMigration, error_message
  end

  def build_error_message(failed_migrations, total_count)
    failed_records = format_failed_records(failed_migrations)

    <<~ERROR
      Migration failed: #{failed_migrations.count} out of #{total_count} hostgroup content facets could not be migrated.

      Failed records:
      #{failed_records}

      HOW TO FIX:
      For each failed hostgroup listed above, you need to ensure the content view is published and promoted
      to the lifecycle environment before running this migration:

      1. Identify the Content View and Lifecycle Environment from the IDs above
      2. If the reason is "ContentViewEnvironment not found":
         - Publish the content view if it hasn't been published yet
         - Promote the published version to the lifecycle environment
         - Verify with: ContentViewEnvironment.find_by(content_view_id: <CV_ID>, environment_id: <LCE_ID>)

      3. If the reason is "Could not find organization for hostgroup":
         - The content view or lifecycle environment may have been deleted
         - Update the hostgroup to use valid content view and lifecycle environment
         - Or set both to nil if the hostgroup should not have content settings

      4. After fixing the issues, retry the migration with: rake db:migrate

      Alternatively, you can use the Rails console to fix individual hostgroups:
        hostgroup = Hostgroup.find(<hostgroup_id>)
        hostgroup.content_facet.content_view = ContentView.find(<valid_cv_id>)
        hostgroup.content_facet.lifecycle_environment = KTEnvironment.find(<valid_lce_id>)
        hostgroup.save!
    ERROR
  end

  def format_failed_records(failed_migrations)
    records = failed_migrations.map do |f|
      "  - Hostgroup: '#{f[:hostgroup_name]}' (ID: #{f[:hostgroup_id]}, Facet ID: #{f[:content_facet_id]})" \
      "\n    Content View ID: #{f[:content_view_id]}, Lifecycle Environment ID: #{f[:lifecycle_environment_id]}" \
      "\n    Reason: #{f[:reason]}"
    end
    records.join("\n")
  end
end
