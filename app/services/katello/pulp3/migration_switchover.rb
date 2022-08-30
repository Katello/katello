require 'pulp_2to3_migration_client'

module Katello
  module Pulp3
    class SwitchOverError < StandardError; end

    class MigrationSwitchover
      def initialize(*argv)
        @migration = Katello::Pulp3::Migration.new(*argv)
      end

      def content_types
        @migration.content_types_for_migration
      end

      def run
        Katello::Logging.time("CONTENT_SWITCHOVER - Total Switchover Process") do
          Katello::Logging.time("CONTENT_SWITCHOVER - check_already_migrated_content") { check_already_migrated_content }
          Katello::Logging.time("CONTENT_SWITCHOVER - correct_docker_meta_tags") { correct_docker_meta_tags } if docker_migration?
          Katello::Logging.time("CONTENT_SWITCHOVER - cleanup_v1_docker_tags") { cleanup_v1_docker_tags } if docker_migration?
          Katello::Logging.time("CONTENT_SWITCHOVER - migrated_content_type_check") { migrated_content_type_check }
          Katello::Logging.time("CONTENT_SWITCHOVER - combine_duplicate_content_types") { combine_duplicate_content_types }
          Katello::Logging.time("CONTENT_SWITCHOVER - combine_duplicate_docker_tags") { combine_duplicate_docker_tags } if docker_migration?
          Katello::Logging.time("CONTENT_SWITCHOVER - migrate_pulp3_hrefs") { migrate_pulp3_hrefs }
          Katello::Logging.time("CONTENT_SWITCHOVER - remove_missing_content") { remove_missing_content }
        end
      end

      def remove_orphaned_content
        models = []
        @migration.repository_types.each do |repo_type_label|
          repo_type = ::Katello::RepositoryTypeManager.repository_types[repo_type_label]
          indexable_types = repo_type.content_types_to_index
          models += indexable_types&.map(&:model_class)
          models.select! { |model| model.many_repository_associations }
        end
        models.each do |model|
          model.joins("left join katello_#{model.repository_association} on #{model.table_name}.id = katello_#{model.repository_association}.#{model.unit_id_field}").where("katello_#{model.repository_association}.#{model.unit_id_field} IS NULL").destroy_all
        end
      end

      def deduplicated_content_types
        #even though YumMetatadataFile is de-depulicated, we're not indexing it in pulp3
        [Katello::PackageGroup]
      end

      def docker_migration?
        content_types.any? { |content_type| content_type.model_class::CONTENT_TYPE == "docker_tag" }
      end

      def migrate_pulp3_hrefs
        content_types.each do |content_type|
          content_type.model_class
              .where.not("pulp_id=migrated_pulp3_href")
              .update_all("pulp_id = migrated_pulp3_href")
        end
      end

      def check_already_migrated_content
        (content_types - Migration.ignorable_content_types).each do |content_type|
          if content_type.model_class.where("pulp_id=migrated_pulp3_href").any?
            Rails.logger.error("Content Switchover: #{content_type.label} seems to have already migrated content, switchover may fail.  Did you already perform the switchover?")
          end
        end
      end

      def correct_docker_meta_tags
        bad_tags = ::Katello::DockerTag.all.select do |t|
          (t.schema1_meta_tag.nil? && t.schema2_meta_tag.nil?) ||
            (t.schema1_meta_tag.present? && t.docker_taggable.schema_version == 2) ||
            (t.schema2_meta_tag.present? && t.docker_taggable.schema_version == 1)
        end

        bad_repos = bad_tags.collect { |t| t.repositories }.flatten.compact.uniq
        bad_repos.each { |r| r.docker_meta_tags.destroy_all }
        bad_repos.each { |r| r.index_content }
        ::Katello::DockerMetaTag.cleanup_tags
      end

      def cleanup_v1_docker_tags
        unmigrated_docker_tags = Katello::DockerTag.includes(:schema1_meta_tag, :schema2_meta_tag).where(migrated_pulp3_href: nil)
        unmigrated_docker_tags.find_in_batches(batch_size: 50_000) do |batch|
          to_delete = []

          batch.each do |unmigrated_tag|
            if unmigrated_tag.schema1_meta_tag && unmigrated_tag.schema1_meta_tag.schema2.try(:migrated_pulp3_href)
              Rails.logger.warn("Content Switchover: Deleting Docker tag #{unmigrated_tag.name} with pulp id: #{unmigrated_tag.pulp_id}")
              to_delete << unmigrated_tag.id
            end
          end
          Katello::DockerMetaTag.where(:schema1_id => to_delete).update_all(:schema1_id => nil)
          Katello::RepositoryDockerTag.where(:docker_tag_id => to_delete).delete_all
          Katello::DockerTag.where(:id => to_delete).delete_all
        end

        Katello::DockerMetaTag.cleanup_tags
      end

      def combine_duplicate_content_types
        deduplicated_content_types.each do |content_class|
          to_delete = []
          content_class.having("count(migrated_pulp3_href) > 1").group(:migrated_pulp3_href).pluck(:migrated_pulp3_href).each do |duplicate_href|
            units = content_class.where(:migrated_pulp3_href => duplicate_href).to_a
            main_unit = units.pop
            content_class.repository_association_class.where(content_class.unit_id_field => units.map(&:id)).update_all(content_class.unit_id_field => main_unit.id)
            to_delete += units.map(&:id)
          end

          to_delete.each_slice(10_000) do |group|
            content_class.where(:id => group).delete_all
          end
        end
      end

      def combine_duplicate_docker_tags
        to_delete = []
        Katello::DockerTag.having("count(migrated_pulp3_href) > 1").group(:migrated_pulp3_href).pluck(:migrated_pulp3_href).each do |duplicate_href|
          tags = Katello::DockerTag.where(:migrated_pulp3_href => duplicate_href).includes(:schema1_meta_tag, :schema2_meta_tag).to_a
          # The duplicates should either have a schema 1 meta tag or a schema 2 meta tag. Skip those with neither.
          main_tag = tags.detect { |tag| tag.schema1_meta_tag.present? || tag.schema2_meta_tag.present? }
          if main_tag.present?
            tags -= [main_tag]
          else
            main_tag = tags.pop
          end
          main_meta_v1 = main_tag.schema1_meta_tag
          main_meta_v2 = main_tag.schema2_meta_tag

          Katello::RepositoryDockerTag.where(:docker_tag_id => tags.map(&:id)).update_all(:docker_tag_id => main_tag.id)
          Katello::RepositoryDockerMetaTag.joins(:docker_meta_tag).where("#{Katello::DockerMetaTag.table_name}.schema1_id" => tags).update_all(:docker_meta_tag_id => main_meta_v1.id) if main_meta_v1
          Katello::RepositoryDockerMetaTag.joins(:docker_meta_tag).where("#{Katello::DockerMetaTag.table_name}.schema2_id" => tags).update_all(:docker_meta_tag_id => main_meta_v2.id) if main_meta_v2

          to_delete += tags.map(&:id)
        end

        to_delete.each_slice(10_000) do |group|
          Katello::RepositoryDockerTag.where(:docker_tag_id => group).delete_all
          Katello::DockerMetaTag.where(:schema1_id => group).or(Katello::DockerMetaTag.where(:schema2_id => group)).delete_all
          Katello::DockerTag.where(:id => group).delete_all
        end
      end

      def remove_missing_content
        content_types.each do |content_type|
          if Migration::CORRUPTABLE_CONTENT_TYPES.include?(content_type.model_class)
            content_type.model_class.ignored_missing_migrated_content.destroy_all
          elsif content_type.model_class == Katello::Erratum
            Katello::RepositoryErratum.where(:erratum_pulp3_href => nil).delete_all
          else
            content_type.model_class.unmigrated_content.destroy_all
          end
        end
      end

      def migrated_content_type_check
        content_classes = content_types.map(&:model_class)
        migrated_errata_check if content_classes.include?(Katello::Erratum)

        (content_classes & Migration::CORRUPTABLE_CONTENT_TYPES).each do |content_type|
          if content_type.missing_migrated_content.any?
            fail SwitchOverError, "ERROR: at least one #{content_type.table_name} record has been detected as corrupt or missing. Run 'foreman-rake katello:pulp3_migration_stats' for more information.\n"
          end

          if content_type.unmigrated_content.any?
            fail SwitchOverError, "ERROR: at least one #{content_type.table_name} record was not able to be migrated\n"
          end
        end
      end

      def migrated_errata_check
        if Katello::RepositoryErratum.where(:erratum_pulp3_href => nil).any?
          fail SwitchOverError, "ERROR: at least one Erratum record has migrated_pulp3_href NULL value\n"
        end
      end
    end
  end
end
