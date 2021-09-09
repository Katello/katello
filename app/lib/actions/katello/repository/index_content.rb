module Actions
  module Katello
    module Repository
      class IndexContent < Actions::EntryAction
        input_format do
          param :id, Integer
          param :source_repository_id
          param :full_index
          param :force_index
        end

        def run
          source_repository = ::Katello::Repository.find(input[:source_repository_id]) if input[:source_repository_id]
          repo = ::Katello::Repository.find(input[:id])

          if input[:force_index] || (repo.last_contents_changed >= repo.last_indexed)
            repo.index_content(source_repository: source_repository, full_index: input[:full_index].present?)
            repo.update(:last_indexed => DateTime.now)
          else
            output[:index_skipped] = true
          end
        end
      end
    end
  end
end
