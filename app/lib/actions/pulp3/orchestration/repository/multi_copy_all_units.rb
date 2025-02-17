module Actions
  module Pulp3
    module Orchestration
      module Repository
        class MultiCopyAllUnits < Pulp3::Abstract
          def plan(extended_repo_map, smart_proxy, options = {})
            solve_dependencies = options.fetch(:solve_dependencies, false)
            if extended_repo_map.values.pluck(:filters).flatten.present? ||
                extended_repo_map.keys.detect { |source_repos| source_repos.length > 1 }
              sequence do
                copy_action = plan_action(Actions::Pulp3::Repository::MultiCopyContent, extended_repo_map, smart_proxy,
                                          solve_dependencies: solve_dependencies)
                plan_action(Actions::Pulp3::Repository::SaveVersions, extended_repo_map.values.pluck(:dest_repo),
                            tasks: copy_action.output[:pulp_tasks])
                repo_id_map = {}
                extended_repo_map.each do |source_repos, dest_repo_map|
                  repo_id_map[source_repos.first.id] = dest_repo_map[:dest_repo].id if dest_repo_map[:filters].blank?
                end
                plan_self(repo_id_map: repo_id_map)
              end
            else
              repo_id_map = {}
              extended_repo_map.each do |source_repos, dest_repo_map|
                repo_id_map[source_repos.first.id] = dest_repo_map[:dest_repo].id
              end
              plan_self(repo_id_map: repo_id_map)
            end
          end

          def run
            input[:repo_id_map].each do |source_repo_id, dest_repo_id|
              dest_repo = ::Katello::Repository.find(dest_repo_id)
              source_repo = ::Katello::Repository.find(source_repo_id)
              dest_repo.update!(version_href: source_repo.version_href)
            end
          end
        end
      end
    end
  end
end
