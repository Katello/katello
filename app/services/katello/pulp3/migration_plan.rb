module Katello
  module Pulp3
    class MigrationPlan
      def initialize(repository_type_labels)
        @repository_types = repository_type_labels
      end

      def primary_proxy
        SmartProxy.pulp_primary!
      end

      def generate
        plan = {}
        Katello::Logging.time("CONTENT_MIGRATION - Generating Migration plan") do
          plan[:plugins] = generate_plugins
        end
        Rails.logger.error("Migration Plan: #{plan.to_json}")
        plan
      end

      def generate_plugins
        @repository_types.sort.map do |repository_type|
          {
            type: self.class.pulp2_repository_type(repository_type),
            repositories: repository_migrations(repository_type)
          }
        end
      end

      def self.pulp2_repository_type(repository_type)
        if repository_type == 'yum'
          return 'rpm' #migration plugin uses rpm
        else
          Katello::RepositoryTypeManager.repository_types[repository_type].service_class::REPOSITORY_TYPE
        end
      end

      def repository_migrations(repo_type)
        roots = Katello::RootRepository.where(:content_type => repo_type).order(:label)
        plans = []
        roots.each do |root|
          plans << library_migration_for(root)
          plans += content_view_migrations_for(root)
        end
        plans.compact.sort_by { |plan| plan[:name] }
      end

      # plugins: [
      #   type: TYPE
      #   repositories: [
      #     {
      #       name: FOO,
      #       pulp2_importer_repository_id: STRING,
      #       repository_versions: [
      #         {
      #           pulp2_repository_id: STRING
      #           pulp2_distributor_repository_ids: [STRING, STRING]
      #         }
      #       ]
      #     }
      #   ]
      # ]

      def library_migration_for(root)
        repo = root.library_instance

        migration = {
          name: repo.pulp_id,
          repository_versions: [
            {
              pulp2_repository_id: repo.pulp_id,
              pulp2_distributor_repository_ids: [repo.pulp_id]
            }
          ]
        }
        migration[:pulp2_importer_repository_id] = repo.pulp_id
        migration
      end

      def content_view_migrations_for(root)
        plans = []
        ContentView.non_default.published_with_repositories(root).sort_by(&:label).each do |cv|
          plans << content_view_migration(cv, root)
        end
        plans
      end

      #since we don't have an easy to look up all 'link' repos for a target, lets
      # pre-generate a map of all target_repo => link_repos
      # This is a fairly inefficient way to do this, but its quite a complex calculation to use AR
      def target_link_map
        return @target_link_map if @target_link_map

        map = {}
        composites_with_repo = ::Katello::ContentViewVersion.where(:content_view_id => ContentView.composite)
        env_repos = Katello::Repository.yum_type.where(:content_view_version_id => composites_with_repo)
        env_repos.each do |link_repo|
          if link_repo.link?
            target = link_repo.target_repository
            map[target] ||= []
            map[target] << link_repo
          end
        end
        @target_link_map = map
      end

      def name_for_content_view(content_view, root_repo)
        "#{content_view.label}-#{root_repo.label}"
      end

      def content_view_migration(content_view, root)
        plan = {
          name: name_for_content_view(content_view, root),
          repository_versions: []
        }
        library_instance = root.library_instance
        content_view.versions.with_library_repo(library_instance).uniq.each do |version|
          archived_repo = version.archived_repos.find_by(:library_instance_id => library_instance.id)
          next if archived_repo.link?

          env_repos = version.repositories.where(:library_instance_id => library_instance.id)
          env_repos += target_link_map[archived_repo] if target_link_map[archived_repo]

          plan[:repository_versions] << {
            pulp2_repository_id: archived_repo.pulp_id,
            pulp2_distributor_repository_ids: env_repos.map(&:pulp_id).uniq.sort
          }
        end

        if plan[:repository_versions].any?
          plan[:repository_versions].sort_by! { |v| v[:pulp2_repository_id] }
          plan
        end
      end
    end
  end
end
