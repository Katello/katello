module Actions
  module ElasticSearch
    module Repository
      class RemovePuppetModules < ElasticSearch::Abstract
        input_format do
          param :pulp_id, String
          param :uuids, Array
        end

        def run
          ::Katello::PuppetModule.remove_indexed_repoid(input[:uuids], input[:pulp_id])
        end
      end
    end
  end
end
