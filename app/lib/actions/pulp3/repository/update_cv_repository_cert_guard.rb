module Actions
  module Pulp3
    module Repository
      class UpdateCVRepositoryCertGuard < Pulp3::Abstract
        def plan(repository, smart_proxy)
          root = repository.root
          cv_repositories = root.repositories - [root.library_instance]
          cv_repositories.each do |repo|
            plan_action(::Actions::Pulp3::Repository::RefreshDistribution, repo, smart_proxy)
          end
        end

        def humanized_name
          _("Updating repository authentication configuration")
        end
      end
    end
  end
end
