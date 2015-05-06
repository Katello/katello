module Actions
  module ElasticSearch
    module Repository
      class IndexContent < ElasticSearch::Abstract
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
