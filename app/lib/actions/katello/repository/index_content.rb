module Actions
  module Katello
    module Repository
      class IndexContent < Actions::EntryAction
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :id, Integer
          param :dependency, Hash
          param :contents_changed
          param :matching_content
          param :source_repository_id
        end

        def run
          source_repository = ::Katello::Repository.find(input[:source_repository_id]) if input[:source_repository_id]
          repo = ::Katello::Repository.find(input[:id])
          repo.index_content(source_repository: source_repository)
        end
      end
    end
  end
end
