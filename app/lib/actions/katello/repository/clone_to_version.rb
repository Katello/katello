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
              plan_action(Repository::CloneYumMetadata, repositories[0], new_repository)
            else
              repositories.each do |repository|
                if new_repository.yum?
                  plan_action(Repository::CloneYumContent, repository, new_repository, filters, :purge_empty_units => !incremental,
                              :generate_metadata => !incremental, :index_content => !incremental, :simple_clone => incremental, :rpm_filenames => rpm_filenames)
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
