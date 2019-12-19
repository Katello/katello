module Katello
  module Pulp3
    class MigrationPlan
      def initialize(repository_type_label)
        @repository_type = repository_type_label
      end

      def master_proxy
        SmartProxy.pulp_master!
      end

      def generate
        plan = {}
        plan[:plugins] = generate_plugins
        Rails.logger.error("Migration Plan: #{plan.to_json}")
        plan
      end

      def generate_plugins
        [
          {
            type: pulp2_repository_type(@repository_type),
            repositories: repository_migrations(@repository_type)
          }
        ]
      end

      def pulp2_repository_type(repository_type)
        Katello::RepositoryTypeManager.repository_types[repository_type].service_class::REPOSITORY_TYPE
      end

      def repository_migrations(repo_type)
        roots = Katello::RootRepository.where(:content_type => repo_type)
        plans = []
        roots.each do |root|
          plans << library_migration_for(root)
          plans += content_view_migrations_for(root)
        end
        plans
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
        ContentView.non_default.published_with_repositories(root).each do |cv|
          plans << content_view_migration(cv, root)
        end
        plans
      end

      def content_view_migration(content_view, root)
        plan = {
          name: "#{content_view.name}-#{root.id}-#{content_view.id}",
          repository_versions: []
        }
        library_instance = root.library_instance
        content_view.versions.with_library_repo(library_instance).uniq.each do |version|
          repo = version.archived_repos.find_by(:library_instance_id => library_instance.id)
          env_repos = version.repositories.where(:library_instance_id => library_instance.id).where.not(:environment_id => nil)
          plan[:repository_versions] << {
            pulp2_repository_id: repo.pulp_id,
            pulp2_distributor_repository_ids: env_repos.map(&:pulp_id)
          }
        end

        plan
      end
    end
  end
end
