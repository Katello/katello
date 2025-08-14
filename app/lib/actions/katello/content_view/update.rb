module Actions
  module Katello
    module ContentView
      class Update < Actions::EntryAction
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

          handle_rolling_content_view(content_view, content_view_params[:repository_ids], environment_ids)
          content_view.update!(content_view_params)
        end

        def handle_rolling_content_view(content_view, target_repo_ids, target_env_ids)
          return unless content_view.rolling?

          add_repo_ids, remove_repo_ids, retain_repo_ids = translate_id_lists(content_view.repository_ids, target_repo_ids)

          if target_env_ids.nil?
            target_env_ids = retain_env_ids = content_view.environment_ids
          else
            add_env_ids, remove_env_ids, retain_env_ids = translate_id_lists(content_view.environment_ids, target_env_ids)
            ::Katello::KTEnvironment.where(id: add_env_ids).each do |environment|
              plan_action(AddToEnvironment, content_view.versions[0], environment)
            end
            plan_action(AddRollingRepoClone, content_view, retain_repo_ids, add_env_ids) if retain_repo_ids.any? && add_env_ids.any?
            ::Katello::KTEnvironment.where(id: remove_env_ids).each do |environment|
              plan_action(RemoveFromEnvironment, content_view, environment)
            end
          end

          plan_action(AddRollingRepoClone, content_view, add_repo_ids, target_env_ids) if add_repo_ids.any?
          plan_action(RemoveRollingRepoClone, content_view, remove_repo_ids, retain_env_ids) if remove_repo_ids.any?
        end

        def translate_id_lists(current_ids, target_ids)
          if target_ids.nil?
            add_ids = remove_ids = []
            retain_ids = current_ids
          else
            add_ids = target_ids - current_ids
            remove_ids = current_ids - target_ids
            retain_ids = current_ids - remove_ids
          end
          return add_ids, remove_ids, retain_ids
        end
      end
    end
  end
end
