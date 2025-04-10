module Actions
  module Katello
    module ContentView
      class Update < Actions::EntryAction
        # rubocop:disable Metrics/AbcSize
        def plan(content_view, content_view_params, environment_ids)
          action_subject content_view
          content_view_params = content_view_params.with_indifferent_access

          # If we are removing repositories, remove their filter rules
          if content_view.filters.present? && content_view.repository_ids.present? && content_view_params.key?(:repository_ids)
            repo_ids_to_remove = content_view.repository_ids - content_view_params[:repository_ids]
            if repo_ids_to_remove.present?
              # Only yum-type repositories have by-ID filter rules
              old_repos = content_view.repositories.yum_type
              new_repos = ::Katello::Repository.where(id: content_view_params[:repository_ids]).yum_type

              lost_module_stream_ids = (::Katello::ModuleStream.in_repositories(old_repos) -
                ::Katello::ModuleStream.in_repositories(new_repos)).pluck(:id)
              ::Katello::ContentViewModuleStreamFilterRule.in_content_views([content_view.id]).where(module_stream_id: lost_module_stream_ids).delete_all

              lost_errata_ids = (::Katello::Erratum.in_repositories(old_repos) -
                ::Katello::Erratum.in_repositories(new_repos)).pluck(:errata_id)
              ::Katello::ContentViewErratumFilterRule.in_content_views([content_view.id]).where(errata_id: lost_errata_ids).delete_all

              lost_package_group_hrefs = (::Katello::PackageGroup.in_repositories(old_repos) -
                ::Katello::PackageGroup.in_repositories(new_repos)).pluck(:pulp_id)
              ::Katello::ContentViewPackageGroupFilterRule.in_content_views([content_view.id]).where(uuid: lost_package_group_hrefs).delete_all
            end
          end

          if content_view.rolling?
            repo_ids_to_add = repo_ids_to_remove = []
            retained_repo_ids = content_view.repository_ids
            if content_view_params.key?(:repository_ids)
              repo_ids_to_add = content_view_params[:repository_ids] - content_view.repository_ids
              repo_ids_to_remove = content_view.repository_ids - content_view_params[:repository_ids]
              retained_repo_ids -= repo_ids_to_remove
            end
            unless environment_ids.nil?
              environment_ids_to_add = environment_ids - content_view.environment_ids
              environment_ids_to_remove = content_view.environment_ids - environment_ids

              ::Katello::KTEnvironment.where(id: environment_ids_to_add).each do |environment|
                plan_action(AddToEnvironment, content_view.versions[0], environment)
              end
              plan_action(AddRollingRepoClone, content_view, retained_repo_ids, environment_ids_to_add) if retained_repo_ids.any? && environment_ids_to_add.any?

              ::Katello::KTEnvironment.where(id: environment_ids_to_remove).each do |environment|
                plan_action(RemoveFromEnvironment, content_view, environment)
              end
            end
            plan_action(AddRollingRepoClone, content_view, repo_ids_to_add, environment_ids) if repo_ids_to_add.any?
            plan_action(RemoveRollingRepoClone, content_view, repo_ids_to_remove, environment_ids) if repo_ids_to_remove.any?
          end

          content_view.update!(content_view_params)
        end
      end
    end
  end
end
