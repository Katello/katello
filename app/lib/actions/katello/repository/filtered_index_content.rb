module Actions
  module Katello
    module Repository
      class FilteredIndexContent < Actions::EntryAction
        input_format do
          param :id, Integer
          param :filter
          param :dependency
          param :content_type
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          if repo.puppet?
            ::Katello::PuppetModule.import_for_repository(repo)
          elsif repo.docker?
            ::Katello::DockerManifest.import_for_repository(repo)
            ::Katello::DockerTag.import_for_repository(repo)
            ::Katello::DockerManifestList.import_for_repository(repo)
          elsif repo.file?
            ::Katello::FileUnit.import_for_repository(repo)
          elsif repo.deb?
            unit_ids = search_units(repo)
            ::Katello::Deb.import_all(unit_ids, repo)
          elsif repo.yum?
            unit_ids = search_units(repo)
            if input[:content_type] == 'srpm'
              ::Katello::Srpm.import_all(unit_ids, repo)
            else
              ::Katello::Rpm.import_all(unit_ids, repo)
            end
          end
        end

        private

        def search_units(repo)
          found = repo.unit_search(:type_ids => [input[:content_type]],
                                   :filters => input[:filter])
          found.map { |result| result.try(:[], :unit_id) }.compact
        end
      end
    end
  end
end
