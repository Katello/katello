module Actions
  module Katello
    module Repository
      class IndexPackageGroups < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(repository)
          plan_self(:user_id => ::User.current.id, :id => repository.id)
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          ::Katello::PackageGroup.import_for_repository(repo)
        end
      end
    end
  end
end
