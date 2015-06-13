module Actions
  module ElasticSearch
    module Repository
      class Destroy < ElasticSearch::Abstract
        input_format do
          param :pulp_id, Integer
        end

        def run
          indexed_puppet_module_ids = ::Katello::PuppetModule.indexed_ids_for_repo(pulp_id)

          ::Katello::PuppetModule.remove_indexed_repoid(indexed_puppet_module_ids, pulp_id)
        end

        def pulp_id
          self.input[:pulp_id]
        end
      end
    end
  end
end
