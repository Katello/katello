require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a Pulp 3 migration of pulp3 hrefs to pulp ids for supported content types."
  task :pulp3_content_switchover => :environment do
    migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_master)
    content_types = migration_service.content_types_for_migration

    if content_types.any? { |content_type| content_type.model_class::CONTENT_TYPE == "docker_tag" }
      unmigrated_docker_tags = Katello::DockerTag.includes(:schema1_meta_tag, :schema2_meta_tag).where(migrated_pulp3_href: nil)
      unmigrated_docker_tags.each do |unmigrated_tag|
        if unmigrated_tag.schema1_meta_tag && unmigrated_tag.schema1_meta_tag.schema2.try(:migrated_pulp3_href)
          puts "\e[33mDeleting Docker tag #{unmigrated_tag.name} with pulp id: #{unmigrated_tag.pulp_id}\e[0m\n\n"
          unmigrated_tag.destroy!
        end
      end
      Katello::DockerMetaTag.cleanup_tags
    end

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
