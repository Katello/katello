module Actions
  module Pulp3
    module Orchestration
      module Repository
        class MultiCopyAllUnits < Pulp3::Abstract
          def plan(extended_repo_map, smart_proxy, options = {})
            solve_dependencies = options.fetch(:solve_dependencies, false)
            # Since this is currently used only for Pulp 3 yum dep solving, just copy all units.
            if solve_dependencies
              sequence do
                copy_action = plan_action(Actions::Pulp3::Repository::MultiCopyContent, extended_repo_map, smart_proxy,
                                          solve_dependencies: solve_dependencies)
                plan_action(Actions::Pulp3::Repository::SaveVersions, extended_repo_map.values.pluck(:dest_repo),
                            tasks: copy_action.output[:pulp_tasks])
              end
            end
          end
        end
      end
    end
  end
end
