module Actions
  module ElasticSearch
    module Repository
      class FilteredIndexContent < ElasticSearch::Abstract
        input_format do
          param :id, Integer
          param :filter
          param :dependency
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          unit_ids = search_units(repo)
          if repo.puppet?
            ::Katello::PuppetModule.index_puppet_modules(unit_ids)
          elsif repo.docker?
            # have to call Repository#index_db_docker_images to get the repo's tags
            repo.index_db_docker_images
          else
            ::Katello::Rpm.import_all(unit_ids, true)
          end
        end

        private

        def search_units(repo)
          found = repo.unit_search(:type_ids => [repo.unit_type_id],
                                   :filters => input[:filter])
          found.map { |result| result.try(:[], :unit_id) }.compact
        end
      end
    end
  end
end
