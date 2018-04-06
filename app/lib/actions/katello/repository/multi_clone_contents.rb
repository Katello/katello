module Actions
  module Katello
    module Repository
      class MultiCloneContents < Actions::Base
        include Actions::Katello::CheckMatchingContent

        def plan(extended_repo_mapping, options)
          generate_metadata = options.fetch(:generate_metadata, true)
          copy_contents = options.fetch(:copy_contents, true)
          solve_dependencies = options.fetch(:solve_dependencies, false)

          sequence do
            if copy_contents
              plan_action(Pulp3::Orchestration::Repository::MultiCopyAllUnits,
                          extended_repo_mapping,
                          SmartProxy.pulp_primary,
                          solve_dependencies: solve_dependencies)
            end

            concurrence do
              extended_repo_mapping.each do |source_repos, dest_repo_map|
                dest_repo_map[:matching_content] = check_matching_content(dest_repo_map[:dest_repo], source_repos)

                if source_repos.first.deb?
                  plan_action(Actions::Katello::Repository::CopyDebErratum,
                              source_repo_id: source_repos.first.id,
                              target_repo_id: dest_repo_map[:dest_repo].id)
                end

                if generate_metadata
                  metadata_generate(source_repos, dest_repo_map[:dest_repo], dest_repo_map[:filters], dest_repo_map[:matching_content])
                end
              end

              extended_repo_mapping.values.each do |dest_repo_map|
                plan_action(Katello::Repository::IndexContent, id: dest_repo_map[:dest_repo].id)
              end
            end
          end
        end

        def metadata_generate(source_repositories, new_repository, filters, matching_content)
          metadata_options = {}

          metadata_options[:matching_content] = matching_content

          if source_repositories.count == 1 && filters.empty?
            metadata_options[:source_repository] = source_repositories.first
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
