module Actions
  module Katello
    module Repository
      class CloneContents < Actions::Base
        include Actions::Katello::CheckMatchingContent

        def plan(source_repositories, new_repository, options)
          filters = options.fetch(:filters, nil)
          rpm_filenames = options.fetch(:rpm_filenames, nil)
          generate_metadata = options.fetch(:generate_metadata, true)
          copy_contents = options.fetch(:copy_contents, true)
          solve_dependencies = options.fetch(:solve_dependencies, false)

          sequence do
            if copy_contents
              plan_action(Pulp3::Orchestration::Repository::CopyAllUnits,
                          new_repository,
                          SmartProxy.pulp_primary,
                          source_repositories,
                          filters: filters, rpm_filenames: rpm_filenames, solve_dependencies: solve_dependencies)
            end

            matching_content = check_matching_content(new_repository, source_repositories)
            metadata_generate(source_repositories, new_repository, filters, rpm_filenames, matching_content) if generate_metadata

            index_options = {id: new_repository.id, force_index: true}
            index_options[:source_repository_id] = source_repositories.first.id if source_repositories.count == 1 && filters.empty? && rpm_filenames.nil?
            plan_action(Katello::Repository::IndexContent, **index_options)
          end
        end

        def metadata_generate(source_repositories, new_repository, filters, rpm_filenames, matching_content)
          metadata_options = {}

          metadata_options[:matching_content] = matching_content

          if source_repositories.count == 1 && filters.empty? && rpm_filenames.empty?
            metadata_options[:source_repository] = source_repositories.first
          end

          plan_action(Katello::Repository::MetadataGenerate, new_repository, **metadata_options)
          unless source_repositories.first.saved_checksum_type == new_repository.saved_checksum_type
            plan_self(:source_checksum_type => source_repositories.first.saved_checksum_type,
                      :target_repo_id => new_repository.id)
          end
        end

        def finalize
          repository = ::Katello::Repository.find(input[:target_repo_id])
          source_checksum_type = input[:source_checksum_type]
          repository.update!(saved_checksum_type: source_checksum_type) if (repository && source_checksum_type)
        end
      end
    end
  end
end
