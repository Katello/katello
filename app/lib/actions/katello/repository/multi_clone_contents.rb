module Actions
  module Katello
    module Repository
      class MultiCloneContents < Actions::Base
        include Actions::Katello::PulpSelector
        def plan(extended_repo_mapping, options)
          generate_metadata = options.fetch(:generate_metadata, true)
          copy_contents = options.fetch(:copy_contents, true)
          solve_dependencies = options.fetch(:solve_dependencies, false)

          sequence do
            if copy_contents
              plan_action(Pulp3::Orchestration::Repository::MultiCopyAllUnits,
                          extended_repo_mapping,
                          SmartProxy.pulp_master,
                          solve_dependencies: solve_dependencies)
            end

            extended_repo_mapping.each do |source_repos, dest_repo_map|
              if generate_metadata
                metadata_generate(source_repos, dest_repo_map[:dest_repo], dest_repo_map[:filters])
              end
            end

            extended_repo_mapping.values.each do |dest_repo_map|
              plan_action(Katello::Repository::IndexContent, id: dest_repo_map[:dest_repo].id)
            end
          end
        end

        def metadata_generate(source_repositories, new_repository, filters)
          metadata_options = {}

          if source_repositories.count == 1 && filters.empty?
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
