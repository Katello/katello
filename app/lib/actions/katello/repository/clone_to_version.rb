module Actions
  module Katello
    module Repository
      class CloneToVersion < Actions::Base
        def plan(repositories, content_view_version, destination_repository, options = {})
          incremental = options.fetch(:incremental, false)
          content_view = content_view_version.content_view
          solve_dependencies = options.fetch(:solve_dependencies, content_view.solve_dependencies)
          pulp_copy_only = options.fetch(:pulp_copy_only, false)
          filters = incremental ? [] : content_view.filters.applicable(repositories.first)
          rpm_filenames = extract_rpm_filenames(options.fetch(:repos_units, nil), repositories.first.label)
          fail _('Cannot publish a composite with rpm filenames') if content_view.composite? && rpm_filenames&.any?
          if rpm_filenames&.any?
            verify_rpm_filenames(repositories.first, rpm_filenames)
            Rails.logger.warn("Filters on content view have been overridden by passed-in filename list during publish") if filters.any?
          end

          copy_contents = destination_repository.primary?
          fail _('Cannot publish a link repository if multiple component clones are specified') if !copy_contents && repositories.count > 1

          sequence do
            plan_action(::Actions::Katello::Repository::CloneContents, repositories, destination_repository,
                        purge_empty_contents: true,
                        filters: filters,
                        rpm_filenames: rpm_filenames,
                        copy_contents: copy_contents,
                        solve_dependencies: solve_dependencies,
                        metadata_generate: !incremental,
                        pulp_copy_only: pulp_copy_only)
          end
        end

        def verify_rpm_filenames(repo, filenames)
          rpms_available = repo.rpms.pluck(:filename)
          filenames.each do |filename|
            fail "%s not available in repository %s" % [filename, repo.label] unless rpms_available.include? filename
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
