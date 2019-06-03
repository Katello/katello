module Actions
  module Pulp
    module Orchestration
      module Repository
        class CopyAllUnits < Pulp::Abstract
          def plan(target_repo, smart_proxy, source_repos, options = {})
            source_repos.each do |source_repo|
              plan_action(Pulp::Repository::CopyAllUnits,
                          target_repo,
                          smart_proxy,
                          source_repo,
                          options)
            end
          end
        end
      end
    end
  end
end
