module Actions
  module Katello
    module Repository
      class MultiCloneToVersion < Actions::Base
        def plan(repository_mapping, content_view_version, options = {})
          incremental = options.fetch(:incremental, false)
          content_view = content_view_version.content_view
          extended_repo_map = extended_repo_mapping(repository_mapping, content_view,
                                                    options.fetch(:repos_units, nil), incremental)
          sequence do
            plan_action(::Actions::Katello::Repository::MultiCloneContents, extended_repo_map,
                        purge_empty_contents: true,
                        copy_contents: true,
                        solve_dependencies: content_view.solve_dependencies,
                        metadata_generate: !incremental)
          end
        end

        def extended_repo_mapping(repo_map, content_view, repos_units, incremental)
          # Example: {[source_repos] => {dest_repo: dest_repo, filters: filters}}
          extended_repo_map = {}
          repo_map.each do |source_repos, dest_repo|
            filters = incremental ? [] : content_view.filters.applicable(source_repos.first)
            extended_repo_map[source_repos] = { :dest_repo => dest_repo,
                                                :filters => filters }
          end
          extended_repo_map
        end
      end
    end
  end
end
