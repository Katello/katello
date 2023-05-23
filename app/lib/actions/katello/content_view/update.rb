module Actions
  module Katello
    module ContentView
      class Update < Actions::EntryAction
        def plan(content_view, content_view_params)
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

          content_view.update!(content_view_params)
        end
      end
    end
  end
end
