require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a post Pulp3 migration check for supported content types."
  task :pulp3_post_migration_check => :environment do
    repository_types = Katello::Pulp3::Migration::REPOSITORY_TYPES

    repository_types.each do |type|
      filter = 'version_href is NULL OR remote_href is NULL'

      unless type == Katello::Repository::DOCKER_TYPE
        filter += ' OR publication_href is NULL'
      end
      repositories = Katello::Repository.with_type(type).where(filter)

      if repositories.any?
        $stderr.print("ERROR: #{type} repository #{repositories.first.id} has a NULL value for remote_href, version_href, publication_href\n")
        exit 1
      end

      non_archived_repositories = Katello::Repository.with_type(type).non_archived
      with_no_distribution_references = non_archived_repositories
        .left_outer_joins(:distribution_references)
        .where(katello_distribution_references: { id: nil })

      if with_no_distribution_references.any?
        $stderr.print("ERROR: A non-archive #{type} repository #{with_no_distribution_references.first.id} did not have a distribution reference\n")
        exit 1
      end
    end
  end
end
