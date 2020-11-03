namespace :katello do
  desc "Retrieve Pulp 2 -> Pulp 3 content migration stats"
  task :pulp3_migration_stats => [:environment] do
    User.current = User.anonymous_admin

    migrated_rpms = ::Katello::Rpm.where('pulp_id LIKE ?', '%/pulp/api/v3/content/rpm/packages/%').
      or(::Katello::Rpm.where.not(migrated_pulp3_href: nil)).count
    migrated_errata = ::Katello::RepositoryErratum.where.not(erratum_pulp3_href: nil).count
    migrated_repos = ::Katello::Repository.where.not(version_href: nil).count
    migratable_repos = ::Katello::Repository.count - ::Katello::Repository.puppet_type.count -
      ::Katello::Repository.ostree_type.count - ::Katello::Repository.deb_type.count

    puts
    puts "Migrated/Total RPMs: #{migrated_rpms}/#{::Katello::Rpm.count}"
    puts "Migrated/Total errata: #{migrated_errata}/#{::Katello::RepositoryErratum.count}"
    puts "Migrated/Total repositories: #{migrated_repos}/#{migratable_repos}"
    puts
    puts "\e[33mNote:\e[0m ensure there is sufficient storage space for /var/lib/pulp/published to double in size before starting the migration process."
    puts "Check the size of /var/lib/pulp/published with 'du -sh /var/lib/pulp/published/'"
  end
end
