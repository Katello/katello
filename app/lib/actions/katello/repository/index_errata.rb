module Actions
  module Katello
    module Repository
      class IndexErrata < Actions::EntryAction
        def plan(repository)
          plan_self(:user_id => ::User.current.id, :id => repository.id)
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          ::Katello::Erratum.import_for_repository(repo)
        end
      end
    end
  end
end
