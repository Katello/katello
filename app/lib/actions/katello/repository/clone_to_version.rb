module Actions
  module Katello
    module Repository
      class CloneToVersion < Actions::Base
        # allows accessing the build object from the superior action
        attr_accessor :new_repository

        def plan(repositories, content_view_version, options = {})
          incremental = options.fetch(:incremental, false)
          content_view = content_view_version.content_view
          filters = incremental ? [] : content_view.filters.applicable(repositories.first)

          self.new_repository = repositories.first.build_clone(content_view: content_view,
                                                               version: content_view_version)

          rpm_filenames = extract_rpm_filenames(options.fetch(:repos_units, nil), repositories.first.label)

          sequence do
            plan_action(Repository::Create, new_repository, true, false)

            if new_repository.link?
              fail "Cannot clone metadata if more than one repository" if repositories.count > 1
              plan_action(Repository::CloneYumMetadata, repositories[0], new_repository,
                                                            :force_yum_metadata_regeneration => true)
            else
              clone_repository_content(repositories, new_repository, filters, incremental, rpm_filenames)
            end

            plan_action(Katello::Repository::MetadataGenerate, new_repository) if repositories.length > 1
          end
        end

        def clone_repository_content(repositories, new_repository, filters, incremental, rpm_filenames)
          repositories.each do |repository|
            if new_repository.yum?
              # If there is more than one repository passed here, that means that there are duplicate repos in a composite content view.
              # We skip generating metadata in this case and generate it later to prevent conflicting data, such as filters.
              skip_metadata = incremental || repositories.length > 1
              plan_action(Repository::CloneYumContent, repository, new_repository, filters, :purge_empty_units => !incremental,
                          :generate_metadata => !skip_metadata, :index_content => !incremental,
                          :simple_clone => incremental, :rpm_filenames => rpm_filenames)
            elsif new_repository.deb?
              plan_action(Repository::CloneDebContent, repository, new_repository, filters, !incremental,
                          :generate_metadata => !incremental, :index_content => !incremental, :simple_clone => incremental)
            elsif new_repository.docker?
              plan_action(Repository::CloneDockerContent, repository, new_repository, filters)
            elsif new_repository.ostree?
              plan_action(Repository::CloneOstreeContent, repository, new_repository)
            elsif new_repository.file?
              plan_action(Repository::CloneFileContent, repository, new_repository)
            end
          end
        end

        def extract_rpm_filenames(repos_units, repo_label)
          return if repos_units.blank?

          repo_units = repos_units.detect { |r| r[:label] == repo_label }
          return if repo_units.blank?

          repo_units.fetch(:rpm_filenames, nil)
        end
      end
    end
  end
end
