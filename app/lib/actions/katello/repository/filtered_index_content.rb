module Actions
  module Katello
    module Repository
      class FilteredIndexContent < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id, Integer
          param :filter
          param :dependency
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          unit_ids = search_units(repo)
          if repo.puppet?
            ::Katello::PuppetModule.import_for_repository(repo)
          elsif repo.docker?
            ::Katello::DockerManifest.import_for_repository(repo)
          elsif repo.file?
            ::Katello::FileUnit.import_for_repository(repo)
          elsif repo.deb?
            ::Katello::Deb.import_all(unit_ids)
          else
            ::Katello::Rpm.import_all(unit_ids)
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
