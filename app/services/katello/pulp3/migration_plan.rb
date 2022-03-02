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
        plan
      end

      def generate_plugins
        plugins = @repository_types.sort.map do |repository_type|
          {
            type: self.class.pulp2_repository_type(repository_type),
            repositories: repository_migrations(repository_type)
          }
        end
        plugins.select { |plugin| plugin[:repositories].any? }
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
          next unless root.library_instance
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

        return nil unless library_repo_safe_to_migrate?(repo)

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

      def library_repo_safe_to_migrate?(repo)
        publish_tasks = ForemanTasks::Task.where(label: 'Actions::Katello::ContentView::Publish')
        publishing_repo_ids = publish_tasks.where(state: ['scheduled', 'running']).collect do |task|
          ::Katello::ContentViewVersion.find(task.input[:content_view_version_id]).library_repos.pluck(:id)
        end
        publishing_repo_ids = publishing_repo_ids.flatten

        if publishing_repo_ids.include?(repo.id)
          warn_string = "Library repository with ID #{repo.id} and name #{repo.name} unmigrated due to being "\
            "associated with an actively-publishing content view.  The migration will need to be run again."
          Rails.logger.warn(warn_string)
          return false
        end

        create_root_tasks = ForemanTasks::Task.where(label: 'Actions::Katello::Repository::CreateRoot')
        active_creation_task = create_root_tasks.where(state: ['scheduled', 'running']).detect do |task|
          task.input[:repository][:id] == repo.id
        end

        if active_creation_task.present?
          warn_string = "Repository with ID #{repo.id} and name #{repo.name} unmigrated due to being "\
            "created during the Pulp 3 migration.  The migration will need to be run again."
          Rails.logger.warn(warn_string)
          return false
        end
        true
      end

      def content_view_migrations_for(root)
        publish_tasks = ForemanTasks::Task.where(label: 'Actions::Katello::ContentView::Publish')
        publishing_cv_ids = publish_tasks.where(state: ['scheduled', 'running']).collect do |task|
          task.input[:content_view_id]
        end

        plans = []
        ContentView.non_default.published_with_repositories(root).sort_by(&:label).each do |cv|
          if publishing_cv_ids.include?(cv.id)
            warn_string = "Repositories belonging to Content View with ID #{cv.id} and name #{cv.name} unmigrated "\
              "due to being created during the Pulp 3 migration.  The migration will need to be run again."
            Rails.logger.warn(warn_string)
          else
            plans << content_view_migration(cv, root)
          end
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
        name = "#{content_view.label}-#{root_repo.label}"

        if Katello::RootRepository.where(:label => root_repo.label).group(:label).count(:label)[root_repo.label] > 1
          repo_query = Katello::Repository.joins(:root, :content_view_version => :content_view).
              where("#{::Katello::RootRepository.table_name}.id != #{root_repo.id}").
              where("#{::Katello::RootRepository.table_name}.label" => root_repo.label, "#{::Katello::ContentView.table_name}.label" => content_view.label)
          name += "-#{root_repo.id}" if repo_query.any?
        end
        name
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
