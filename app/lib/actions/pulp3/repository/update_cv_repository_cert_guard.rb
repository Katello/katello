module Actions
  module Pulp3
    module Repository
      class UpdateCVRepositoryCertGuard < Pulp3::Abstract
        def plan(repository, _smart_proxy)
          root = repository.root
          cv_repositories = root.repositories - [root.library_instance]
          cv_repositories.each do |repo|
            plan_action(::Actions::Pulp3::Repository::RefreshDistribution, repo, SmartProxy.pulp_master)
          end
        end
      end
    end
  end
end
