require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a Pulp 3 migration of pulp3 hrefs to pulp ids for supported content types."
  task :pulp3_content_switchover => :environment do
    content_types = Katello::Pulp3::Migration.content_types_for_migration

    content_types.each do |content_type|
      if content_type.model_class.where(migrated_pulp3_href: nil).any?
        $stderr.print("ERROR: at least one #{content_type.model_class.table_name} record has migrated_pulp3_href NULL value\n")
        exit 1
      end
    end

    content_types.each do |content_type|
      content_type.model_class
        .where.not("pulp_id=migrated_pulp3_href")
        .update_all("pulp_id = migrated_pulp3_href")
    end
  end
end
