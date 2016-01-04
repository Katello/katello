module Actions
  module Katello
    module Repository
      class IndexContent < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :id, Integer
          param :dependency, Hash
          param :contents_changed
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          repo.index_content
        end
      end
    end
  end
end
