module Actions
  module Katello
    module Repository
      class CloneContents < Actions::Base
        def plan(source_repositories, new_repository, options)
          filters = options.fetch(:filters, [])
          rpm_filenames = options.fetch(:rpm_filenames, nil)
          generate_metadata = options.fetch(:generate_metadata, true)
          copy_contents = options.fetch(:copy_contents, true)
          solve_dependencies = options.fetch(:solve_dependencies, false)
          assume_content_guard_exists = options.fetch(:assume_content_guard_exists, false)
          contents_changed = options.fetch(:contents_changed, true)

          sequence do
            if copy_contents
              plan_action(Pulp3::Orchestration::Repository::CopyAllUnits,
                          new_repository,
                          SmartProxy.pulp_primary,
                          source_repositories,
                          filters: filters, rpm_filenames: rpm_filenames, solve_dependencies: solve_dependencies)
            end

            if generate_metadata
              metadata_generate(source_repositories, new_repository, filters, rpm_filenames, assume_content_guard_exists, contents_changed)
            end

            index_options = {id: new_repository.id, force_index: true}
            index_options[:source_repository_id] = source_repositories.first.id if source_repositories.count == 1 && filters.empty? && rpm_filenames.nil?

            if new_repository.deb? && generate_metadata
              plan_action(Candlepin::Product::ContentUpdate,
                          owner:           new_repository.organization.label,
                          repository_id:   new_repository.id,
                          name:            new_repository.root.name,
                          type:            new_repository.root.content_type,
                          arches:          new_repository.root.format_arches,
                          label:           new_repository.root.custom_content_label,
                          content_url:     new_repository.root.custom_content_path,
                          gpg_key_url:     new_repository.yum_gpg_key_url,
                          metadata_expire: new_repository.root.metadata_expire)
            end

            plan_action(Katello::Repository::IndexContent, index_options)
          end
        end

        def metadata_generate(source_repositories, new_repository, filters, rpm_filenames, assume_content_guard_exists, contents_changed)
          metadata_options = {}

          metadata_options[:assume_content_guard_exists] = assume_content_guard_exists
          metadata_options[:contents_changed] = contents_changed

          if source_repositories.count == 1 && filters.empty? && rpm_filenames.empty?
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
