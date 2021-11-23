namespace :katello do
  desc "Retrieve Pulp 2 -> Pulp 3 content migration stats"
  task :pulp3_migration_stats => [:environment] do
    User.current = User.anonymous_admin

    migrated_deb_count = ::Katello::Deb.where('pulp_id LIKE ?', '%/pulp/api/v3/content/deb/packages/%').
      or(::Katello::Deb.where.not(migrated_pulp3_href: nil)).count
    migrated_rpm_count = ::Katello::Rpm.where('pulp_id LIKE ?', '%/pulp/api/v3/content/rpm/packages/%').
      or(::Katello::Rpm.where.not(migrated_pulp3_href: nil)).count
    migrated_erratum_count = ::Katello::RepositoryErratum.where.not(erratum_pulp3_href: nil).count
    migrated_repo_count = ::Katello::Repository.where.not(version_href: nil).count
    migratable_repo_count = ::Katello::Repository.count - ::Katello::Repository.puppet_type.count -
      ::Katello::Repository.ostree_type.count - ::Katello::Repository.deb_type.count

    immediate_unmigrated_deb_count = ::Katello::Deb.count - migrated_deb_count
    on_demand_rpm_count = Katello::RepositoryRpm.where(:repository_id => Katello::Repository.yum_type.on_demand).
      select(:rpm_id).distinct.count
    on_demand_unmigrated_rpm_count = on_demand_rpm_count - migrated_rpm_count
    immediate_unmigrated_rpm_count = ::Katello::Rpm.count - migrated_rpm_count - on_demand_unmigrated_rpm_count

    # On Demand RPMs: (6.46E-04)*(#RPMs) + -3.22
    # Immediate RPMs: (9.39E-04)*(#RPMs) + -3
    # Repositories: 0.0746*(#Repos) + -2.07
    migration_minutes = (0.000646 * on_demand_unmigrated_rpm_count - 3.22 +
                         0.000943 * immediate_unmigrated_deb_count - 3 + # copied from RPM, no scientific analysis has been done ;-)
                         0.000943 * immediate_unmigrated_rpm_count - 3 +
                         0.0746 * migratable_repo_count).to_i
    hours = (migration_minutes / 60) % 60
    minutes = migration_minutes % 60

    puts "============Migration Summary================"
    puts "Migrated/Total DEBs: #{migrated_deb_count}/#{::Katello::Deb.count}"
    puts "Migrated/Total RPMs: #{migrated_rpm_count}/#{::Katello::Rpm.count}"
    puts "Migrated/Total errata: #{migrated_erratum_count}/#{::Katello::RepositoryErratum.count}"
    puts "Migrated/Total repositories: #{migrated_repo_count}/#{migratable_repo_count}"

    # The timing formulas go negative if the amount of content is negligibly small
    if migration_minutes >= 5
      puts "Estimated migration time based on yum/apt content: #{hours} hours, #{minutes} minutes"
    elsif migrated_rpm_count == ::Katello::Rpm.count &&
      migrated_deb_count == ::Katello::Deb.count &&
      migrated_erratum_count == ::Katello::RepositoryErratum.count &&
      migrated_repo_count == migratable_repo_count
      puts "All content has been migrated."
    else
      puts "Estimated migration time based on yum/apt content: fewer than 5 minutes"
    end

    puts
    puts "\e[33mNote:\e[0m ensure there is sufficient storage space for /var/lib/pulp/published to triple in size before starting the migration process."
    puts "Check the size of /var/lib/pulp/published with 'du -sh /var/lib/pulp/published/'"

    puts
    puts "\e[33mNote:\e[0m ensure there is sufficient storage space for postgresql."
    puts "You will need additional space for your postgresql database.  The partition holding '/var/opt/rh/rh-postgresql12/lib/pgsql/data/'"
    puts "   will need additional free space equivalent to the size of your Mongo db database (/var/lib/mongodb/)."

    displayed_warning = false
    found_missing = false
    path = Dir.mktmpdir('unmigratable_content-')
    Katello::Pulp3::Migration::CORRUPTABLE_CONTENT_TYPES.each do |type|
      if type.missing_migrated_content.any?
        unless displayed_warning
          displayed_warning = true
          puts
          puts "============Missing/Corrupted Content Summary================"
          puts "WARNING: MISSING OR CORRUPTED CONTENT DETECTED"
        end

        found_missing = true
        name = type.name.demodulize
        puts "Corrupted or Missing #{name}: #{type.missing_migrated_content.count}/#{type.count}"

        File.open(File.join(path, name), 'w') do |file|
          text = type.missing_migrated_content.map(&:filename).join("\n") + "\n"
          file.write(text)
        end
      end
    end

    if found_missing
      puts "Corrupted or missing content has been detected, you can examine the list of content in #{path} and take action by either:"
      puts "1. Performing a 'Verify Checksum' sync under Advanced Sync Options, let it complete, and re-running the migration"
      puts "2. Deleting/disabling the affected repositories and running orphan cleanup (foreman-rake katello:delete_orphaned_content) and re-running the migration"
      puts "3. Manually correcting files on the filesystem in /var/lib/pulp/content/ and re-running the migration"
      puts "4. Mark currently corrupted or missing content as skipped (foreman-rake katello:approve_corrupted_migration_content).  This will skip migration of missing or corrupted content."
      puts
    end
  end
end
