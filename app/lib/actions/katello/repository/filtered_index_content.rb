module Actions
  module Katello
    module Repository
      class FilteredIndexContent < Actions::EntryAction
        input_format do
          param :id, Integer
          param :filter
          param :import_upload_task
          param :content_type
          param :upload_actions
        end

        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        # rubocop:disable Metrics/AbcSize
        def run
          repo = ::Katello::Repository.find(input[:id])
          if repo.docker?
            ::Katello::DockerManifest.import_for_repository(repo)
            ::Katello::DockerTag.import_for_repository(repo)
            ::Katello::DockerManifestList.import_for_repository(repo)
          elsif repo.file?
            ::Katello::FileUnit.import_for_repository(repo)
          elsif repo.generic?
            repo.repository_type.content_types_to_index.each do |type|
              type.model_class.import_for_repository(repo, type.content_type)
            end
          elsif repo.deb?
            if input[:import_upload_task] && input[:import_upload_task][:content_unit_href]
              unit_ids = [input[:import_upload_task][:content_unit_href]]
            elsif input[:upload_actions]&.any? { |action| action.try(:[], "content_unit_href") }
              uploaded_content_unit_hrefs = []
              input[:upload_actions].each { |action| uploaded_content_unit_hrefs << action.try(:[], "content_unit_href") }
              unit_ids = uploaded_content_unit_hrefs.compact
            else
              unit_ids = search_units(repo)
            end
            ::Katello::Deb.import_all(unit_ids, repo)
          elsif repo.yum?
            if input[:import_upload_task] && input[:import_upload_task][:content_unit_href]
              unit_ids = [input[:import_upload_task][:content_unit_href]]
            elsif input[:upload_actions]&.any? { |action| action.try(:[], "content_unit_href") }
              uploaded_content_unit_hrefs = []
              input[:upload_actions].each { |action| uploaded_content_unit_hrefs << action.try(:[], "content_unit_href") }
              unit_ids = uploaded_content_unit_hrefs.compact
            else
              unit_ids = search_units(repo)
            end
            if input[:content_type] == ::Katello::Srpm::CONTENT_TYPE
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
