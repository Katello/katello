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

          initial_counts = {}
          repo.repository_type.primary_content_types.each do |content_type|
            initial_counts[content_type.label] = content_type.model_class.in_repositories(repo).count
          end

          if input[:force_index] || (repo.last_contents_changed >= repo.last_indexed)
            repo.index_content(source_repository: source_repository, full_index: input[:full_index].present?)
          else
            output[:index_skipped] = true
          end

          output[:new_content] = {}
          repo.repository_type.primary_content_types.each do |content_type|
            new_count = content_type.model_class.in_repositories(repo).count
            output[:new_content][content_type.label] = new_count - initial_counts[content_type.label]
          end
        end
      end
    end
  end
end
