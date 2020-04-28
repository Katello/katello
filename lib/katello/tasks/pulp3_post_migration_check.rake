require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a post Pulp3 migration check for supported content types."
  task :pulp3_post_migration_check => :environment do
    User.current = User.anonymous_admin
    repository_types = Katello::Pulp3::Migration.repository_types_for_migration

    # Take care of repository deletions
    ForemanTasks.sync_task(Actions::Pulp3::OrphanCleanup::DeleteOrphanedMigratedRepositories, SmartProxy.pulp_primary)

    repository_types.each do |type|
      # check version
      nil_version_ids = Katello::Repository.with_type(type).where(version_href: nil).pluck(:id)
      unless nil_version_ids.empty?
        $stderr.print("ERROR: #{type} repositories with ID [#{nil_version_ids.join(',')}] have a NULL value for version_href\n")
        exit 1
      end

      # check remote
      nil_remote_ids = Katello::Repository.with_type(type).where(remote_href: nil).collect do |repo|
        repo.id if repo.in_default_view? && !repo.root.url.nil?
      end
      nil_remote_ids.compact!
      unless nil_remote_ids.empty?
        $stderr.print("ERROR: #{type} repositories with ID [#{nil_remote_ids.join(',')}] have a NULL value for remote_href\n")
        exit 1
      end

      # check publication
      unless type == Katello::Repository::DOCKER_TYPE
        nil_publication_ids = Katello::Repository.with_type(type).where(publication_href: nil).pluck(:id)
        unless nil_publication_ids.empty?
          $stderr.print("ERROR: #{type} repositories with ID [#{nil_publication_ids.join(',')}] have a NULL value for publication_href\n")
          exit 1
        end
      end

      # check distribution
      non_archived_repositories = Katello::Repository.with_type(type).non_archived
      with_no_distribution_references = non_archived_repositories.
        left_outer_joins(:distribution_references).
        where(katello_distribution_references: { id: nil }).
        pluck(:id)

      if with_no_distribution_references.any?
        $stderr.print("ERROR: Non-archived #{type} repositories with ID [#{with_no_distribution_references.join(',')}] have no distribution reference\n")
        exit 1
      end
    end
  end
end
