namespace :katello do
  desc "Retrieve Pulp 2 -> Pulp 3 content migration stats"
  task :pulp3_migration_stats => [:environment] do
    User.current = User.anonymous_admin

    migrated_rpm_count = ::Katello::Rpm.where('pulp_id LIKE ?', '%/pulp/api/v3/content/rpm/packages/%').
      or(::Katello::Rpm.where.not(migrated_pulp3_href: nil)).count
    migrated_erratum_count = ::Katello::RepositoryErratum.where.not(erratum_pulp3_href: nil).count
    migrated_repo_count = ::Katello::Repository.where.not(version_href: nil).count
    migratable_repo_count = ::Katello::Repository.count - ::Katello::Repository.puppet_type.count -
      ::Katello::Repository.ostree_type.count - ::Katello::Repository.deb_type.count

    on_demand_rpm_count = Katello::RepositoryRpm.where(:repository_id => Katello::Repository.yum_type.on_demand).distinct.count
    on_demand_unmigrated_rpm_count = on_demand_rpm_count - migrated_rpm_count
    immediate_unmigrated_rpm_count = ::Katello::Rpm.count - migrated_rpm_count - on_demand_unmigrated_rpm_count

    # On Demand RPMs: (6.46E-04)*(#RPMs) + -3.22
    # Immediate RPMs: (9.39E-04)*(#RPMs) + -3
    # Repositories: 0.0746*(#Repos) + -2.07
    migration_minutes = (0.000646 * on_demand_unmigrated_rpm_count - 3.22 +
                         0.000943 * immediate_unmigrated_rpm_count - 3 +
                         0.0746 * migratable_repo_count).to_i
    hours = (migration_minutes / 60) % 60
    minutes = migration_minutes % 60

    puts
    puts "Migrated/Total RPMs: #{migrated_rpm_count}/#{::Katello::Rpm.count}"
    puts "Migrated/Total errata: #{migrated_erratum_count}/#{::Katello::RepositoryErratum.count}"
    puts "Migrated/Total repositories: #{migrated_repo_count}/#{migratable_repo_count}"
    puts
    # The timing formulas go negative if the amount of content is negligibly small
    if migration_minutes >= 5
      puts "Estimated migration time based on yum content: #{hours} hours, #{minutes} minutes"
    else
      puts "Estimated migration time based on yum content: fewer than 5 minutes"
    end
    puts
    puts "\e[33mNote:\e[0m ensure there is sufficient storage space for /var/lib/pulp/published to double in size before starting the migration process."
    puts "Check the size of /var/lib/pulp/published with 'du -sh /var/lib/pulp/published/'"
  end
end
