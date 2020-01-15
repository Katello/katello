require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a post Pulp3 migration check for supported content types."
  task :pulp3_post_migration_check => :environment do
    repository_types = Katello::Pulp3::Migration::REPOSITORY_TYPES

    repository_types.each do |type|
      repositories = Katello::Repository.with_type(type)
        .where('version_href is NULL OR remote_href is NULL')
      if repositories.any?
        $stderr.print("ERROR: at least one #{type} repository record has a NULL value for remote_href or version_href")
        exit 1
      end

      repositories = Katello::Repository.with_type(type)
        .where.not(remote_href: nil)
        .where.not(version_href: nil)

      repositories.each do |repository|
        repository.distribution_references.each do |distribution_reference|
          if distribution_reference.href.nil?
            $stderr.print("ERROR: repository id #{repository.id} record has a distribution reference with a NULL value for href")
            exit 1
          end
        end
      end
    end
  end
end
