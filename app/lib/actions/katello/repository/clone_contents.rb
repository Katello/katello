module Actions
  module Katello
    module Repository
      class CloneContents < Actions::Base
        def plan(source_repositories, new_repository, options)
          filters = options.fetch(:filters, nil)
          rpm_filenames = options.fetch(:rpm_filenames, nil)
          generate_metadata = options.fetch(:generate_metadata, true)
          index_content = options.fetch(:index_content, true)
          purge_empty_contents = options.fetch(:purge_empty_contents, false)
          copy_contents = options.fetch(:copy_contents, true)
          solve_dependencies = options.fetch(:solve_dependencies, false)

          sequence do
            if copy_contents
              source_repositories.each do |repository|
                plan_action(Pulp::Repository::CopyAllUnits, repository, new_repository,
                            filters: filters, rpm_filenames: rpm_filenames, solve_dependencies: solve_dependencies)
              end
            end

            metadata_generate(source_repositories, new_repository, filters, rpm_filenames) if generate_metadata

            plan_action(Katello::Repository::IndexContent, id: new_repository.id) if index_content

            if purge_empty_contents && new_repository.backend_service(SmartProxy.pulp_master).should_purge_empty_contents?
              plan_action(Katello::Repository::PurgeEmptyContent, id: new_repository.id)
            end
          end
        end

        def metadata_generate(source_repositories, new_repository, filters, rpm_filenames)
          metadata_options = {}

          if source_repositories.count == 1 && filters.empty? && rpm_filenames.empty?
            metadata_options[:source_repository] = source_repositories.first
          end

          check_matching_content = ::Katello::RepositoryTypeManager.find(new_repository.content_type).metadata_publish_matching_check
          if new_repository.environment && source_repositories.count == 1 && check_matching_content
            match_check_output = plan_action(Katello::Repository::CheckMatchingContent,
                                :source_repo_id => source_repositories.first.id,
                                :target_repo_id => new_repository.id).output

            metadata_options[:matching_content] = match_check_output[:matching_content]
          end

          plan_action(Katello::Repository::MetadataGenerate, new_repository, metadata_options)
        end
      end
    end
  end
end
