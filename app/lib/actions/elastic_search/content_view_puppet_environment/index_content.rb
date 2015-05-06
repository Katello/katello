module Actions
  module ElasticSearch
    module ContentViewPuppetEnvironment
      class IndexContent < ElasticSearch::Abstract
        input_format do
          param :id, Integer
        end

        def run
          puppet_env = ::Katello::ContentViewPuppetEnvironment.find(input[:id])
          puppet_env.index_content
        end
      end
    end
  end
end
