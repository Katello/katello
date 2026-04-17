class AddContentViewEnvironmentToHostgroupContentFacet < ActiveRecord::Migration[6.1]
  class FakeHostgroupContentFacet < ApplicationRecord
    self.table_name = 'katello_hostgroup_content_facets'
  end

  def up
    add_column :katello_hostgroup_content_facets, :content_view_environment_id, :integer

    validation_results = ::Katello::Util::CveHgcfMigrator.new.execute!
    report_validation_results(validation_results)

    migrate_hostgroup_facets

    # Add foreign key and index after data migration
    add_foreign_key :katello_hostgroup_content_facets, :katello_content_view_environments,
                    column: :content_view_environment_id
    add_index :katello_hostgroup_content_facets, :content_view_environment_id,
              name: 'index_katello_hg_content_facets_on_cv_env_id'

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

    # Remove foreign key and index before removing column
    remove_foreign_key :katello_hostgroup_content_facets, :katello_content_view_environments
    remove_index :katello_hostgroup_content_facets, name: 'index_katello_hg_content_facets_on_cv_env_id'
    remove_column :katello_hostgroup_content_facets, :content_view_environment_id
  end

  private

  def report_validation_results(results)
    if results[:partial_data_count] > 0
      say "Found #{results[:partial_data_count]} hostgroup content facets with only CV or LCE set. " \
          "These will be migrated using organization defaults."
    end

    return unless results[:problematic_facets].any?

    say "WARNING: #{results[:problematic_facets].count} hostgroup content facets have " \
        "content_view_id/lifecycle_environment_id combinations that don't match any " \
        "ContentViewEnvironment record. These hostgroups will be left without a content view " \
        "environment and will need to be manually reassigned."
    say "Affected hostgroups:"
    results[:problematic_facets].each do |row|
      say "  - Hostgroup '#{row[:hostgroup_name]}' (ID: #{row[:hostgroup_id]}): " \
          "CV ID #{row[:content_view_id]}, Env ID #{row[:lifecycle_environment_id]}"
    end
  end

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

    # Return counts for decision making
    {
      total_count: total_count,
      success_count: success_count,
      failed_count: failed_migrations.count,
    }
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def migrate_single_facet(hostgroup_facet)
    cv_id = hostgroup_facet.content_view_id
    lce_id = hostgroup_facet.lifecycle_environment_id
    hostgroup = ::Hostgroup.find_by(id: hostgroup_facet.hostgroup_id)

    # If only one of CV or LCE is set, try to inherit from parent first, then use org defaults
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
      # Log the failure with actual values for debugging
      if cv_env_id.blank?
        hg_name = hostgroup&.name || "Unknown"
        hg_id = hostgroup_facet.hostgroup_id
        say "⚠️  Hostgroup '#{hg_name}' (HG ID: #{hg_id}, Facet ID: #{hostgroup_facet.id}): " \
            "content_view_id=#{cv_id}, lifecycle_environment_id=#{lce_id} " \
            "could not be migrated (no matching ContentViewEnvironment found)"
      end

      {
        success: false,
        error_info: build_error_info(hostgroup_facet, hostgroup, cv_id, lce_id, cv_env_id),
      }
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def fill_missing_cv_or_lce(hostgroup_facet, cv_id, lce_id, hostgroup)
    # First, try to inherit missing value from parent hostgroup
    if hostgroup&.ancestry.present?
      inherited_values = find_inherited_cv_or_lce(hostgroup, cv_id, lce_id)
      if inherited_values[:found]
        cv_id = inherited_values[:cv_id] if cv_id.blank?
        lce_id = inherited_values[:lce_id] if lce_id.blank?
        say "Hostgroup content facet #{hostgroup_facet.id} (#{hostgroup.name}) inheriting missing values from parent"
        return { success: true, cv_id: cv_id, lce_id: lce_id }
      end
    end

    # Fall back to organization defaults if no parent has the missing value
    org = find_organization(cv_id, lce_id)

    if org
      say "Hostgroup content facet #{hostgroup_facet.id} has only one of CV/LCE set, using organization defaults"
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

  def find_inherited_cv_or_lce(hostgroup, cv_id, lce_id)
    # Walk up the ancestry chain to find missing CV or LCE values
    # This preserves the old partial inheritance behavior
    ancestor_ids = hostgroup.ancestor_ids.reverse # Start from immediate parent

    ancestor_ids.each do |ancestor_id|
      ancestor_facet = FakeHostgroupContentFacet.find_by(hostgroup_id: ancestor_id)
      next unless ancestor_facet

      # If we're missing CV and ancestor has it, use it
      if cv_id.blank? && ancestor_facet.content_view_id.present?
        cv_id = ancestor_facet.content_view_id
      end

      # If we're missing LCE and ancestor has it, use it
      if lce_id.blank? && ancestor_facet.lifecycle_environment_id.present?
        lce_id = ancestor_facet.lifecycle_environment_id
      end

      # If we found both, we're done
      break if cv_id.present? && lce_id.present?
    end

    # Return whether we found at least one inherited value
    {
      found: cv_id.present? && lce_id.present?,
      cv_id: cv_id,
      lce_id: lce_id,
    }
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
    # Look up names for easier manual fixing
    cv_name = cv_id.present? ? ::Katello::ContentView.find_by(id: cv_id)&.name : nil
    lce_name = lce_id.present? ? ::Katello::KTEnvironment.find_by(id: lce_id)&.name : nil

    {
      content_facet_id: hostgroup_facet.id,
      hostgroup_id: hostgroup_facet.hostgroup_id,
      hostgroup_name: hostgroup&.name || "Unknown",
      content_view_id: cv_id,
      content_view_name: cv_name || "Unknown",
      lifecycle_environment_id: lce_id,
      lifecycle_environment_name: lce_name || "Unknown",
      reason: custom_reason || (cv_env_id.present? ? "Update failed" : "ContentViewEnvironment not found"),
    }
  end

  def write_failed_migrations_to_file(failed_migrations)
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    log_file = Rails.root.join('tmp', "hostgroup_cve_migration_failures_#{timestamp}.log")
    csv_file = Rails.root.join('tmp', "hostgroup_cve_migration_failures_#{timestamp}.csv")

    write_log_file(log_file, failed_migrations)
    write_csv_file(csv_file, failed_migrations)

    say "   CSV file saved to: #{csv_file}"
    log_file.to_s
  end

  def write_log_file(log_file, failed_migrations)
    File.open(log_file, 'w') do |f|
      write_log_header(f)
      write_log_failures(f, failed_migrations)
      f.puts "=" * 80
      f.puts "Total failed: #{failed_migrations.count}"
    end
  end

  def write_log_header(file)
    file.puts "Hostgroup Content View Environment Migration Failures"
    file.puts "Migration timestamp: #{Time.now}"
    file.puts "=" * 80
    file.puts ""
    file.puts "The following hostgroups could not be automatically migrated because their"
    file.puts "content_view_id and lifecycle_environment_id combination does not have a"
    file.puts "corresponding ContentViewEnvironment record."
    file.puts ""
    file.puts "To fix each hostgroup:"
    file.puts "1. Ensure the content view is published and promoted to the lifecycle environment"
    file.puts "2. Edit the hostgroup in the UI and select a Content View Environment"
    file.puts "3. Or use the Rails console:"
    file.puts ""
    file.puts "   hg = Hostgroup.find(<hostgroup_id>)"
    file.puts "   hg.content_view = ContentView.find(<content_view_id>)"
    file.puts "   hg.lifecycle_environment = KTEnvironment.find(<lifecycle_environment_id>)"
    file.puts "   hg.save!"
    file.puts ""
    file.puts "=" * 80
    file.puts ""
  end

  def write_log_failures(file, failed_migrations)
    failed_migrations.each_with_index do |failure, index|
      file.puts "#{index + 1}. Hostgroup: #{failure[:hostgroup_name]} (ID: #{failure[:hostgroup_id]})"
      file.puts "   Content Facet ID: #{failure[:content_facet_id]}"
      file.puts "   Content View: #{failure[:content_view_name]} (ID: #{failure[:content_view_id]})"
      lce_line = "   Lifecycle Environment: #{failure[:lifecycle_environment_name]} " \
                 "(ID: #{failure[:lifecycle_environment_id]})"
      file.puts lce_line
      file.puts "   Reason: #{failure[:reason]}"
      file.puts ""
    end
  end

  def write_csv_file(csv_file, failed_migrations)
    File.open(csv_file, 'w') do |f|
      f.puts csv_header
      failed_migrations.each do |failure|
        f.puts csv_row(failure)
      end
    end
  end

  def csv_header
    "Hostgroup ID,Hostgroup Name,Content Facet ID,Content View ID,Content View Name," \
      "Lifecycle Environment ID,Lifecycle Environment Name,Reason"
  end

  def csv_row(failure)
    "#{failure[:hostgroup_id]},\"#{failure[:hostgroup_name]}\",#{failure[:content_facet_id]}," \
      "#{failure[:content_view_id]},\"#{failure[:content_view_name]}\"," \
      "#{failure[:lifecycle_environment_id]},\"#{failure[:lifecycle_environment_name]}\"," \
      "\"#{failure[:reason]}\""
  end

  def handle_migration_results(failed_migrations, _total_count, success_count)
    if failed_migrations.any?
      log_file = write_failed_migrations_to_file(failed_migrations)

      say "=" * 80
      say "⚠️  WARNING: #{failed_migrations.count} hostgroups could not be migrated"
      say "   These hostgroups will have no Content View Environment set."
      say "   Failed migration details saved to: #{log_file}"
      say "   To fix: Edit each hostgroup and select a Content View Environment"
      say "   Affected hostgroups: #{failed_migrations.map { |e| e[:hostgroup_name] }.join(', ')}"
      say "=" * 80
    else
      say "Successfully migrated all #{success_count} hostgroup content facets"
    end
  end

  def build_error_message(failed_migrations, total_count)
    failed_records = format_failed_records(failed_migrations)

    <<~WARNING
      WARNING: #{failed_migrations.count} out of #{total_count} hostgroup content facets could not be migrated.
      These hostgroups will be left without a content view environment and will need to be manually reassigned.

      Failed records:
      #{failed_records}

      HOW TO FIX:
      You can fix these hostgroups after the migration completes. For each failed hostgroup:

      1. If the reason is "ContentViewEnvironment not found":
         - The content view may not be published or promoted to that lifecycle environment
         - Publish the content view if needed, then promote it to the lifecycle environment
         - Reassign the hostgroup to the correct content view and environment via UI or:
           hostgroup = Hostgroup.find(<hostgroup_id>)
           hostgroup.content_view = ContentView.find(<valid_cv_id>)
           hostgroup.lifecycle_environment = KTEnvironment.find(<valid_lce_id>)
           hostgroup.save!

      2. If the reason is "Could not find organization for hostgroup":
         - The content view or lifecycle environment may have been deleted
         - Reassign the hostgroup to a valid content view and lifecycle environment
         - Or clear both values if the hostgroup should not have content settings
    WARNING
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
