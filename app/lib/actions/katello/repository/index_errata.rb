module Actions
  module Katello
    module Repository
      class IndexErrata < Actions::EntryAction
        def plan(repository)
          plan_self(:user_id => ::User.current.id, :id => repository.id)
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          repo.index_db_errata
        end
      end
    end
  end
end
