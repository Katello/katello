module Actions
  module Katello
    module Repository
      class IndexContent < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id, Integer
          param :dependency, Hash
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          repo.index_content
        end
      end
    end
  end
end
