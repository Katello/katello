module Katello
  module Pulp3
    module ContentViewVersion
      class ExportValidationError < HttpErrors::BadRequest; end
      class ExportValidator
        delegate :content_view_version, :from_content_view_version, :format, :repositories,
                 :smart_proxy, :version_href_to_repository_href, to: :@export_service

        def initialize(export_service:, fail_on_missing_content: true, validate_incremental: true, chunk_size: nil)
          @export_service = export_service
          @fail_on_missing_content = fail_on_missing_content
          @validate_incremental = validate_incremental
          @chunk_size = chunk_size
        end

        def validate!
          validate_repositories_immediate! if @fail_on_missing_content
          validate_incremental_export! if @validate_incremental && !from_content_view_version.blank?
          validate_chunk_size
          validate_export_types! if @fail_on_missing_content
        end

        def validate_chunk_size
          return if @chunk_size.blank?

          unless @chunk_size.is_a?(Numeric) && @chunk_size > 0 && @chunk_size < 1e6
            fail ExportValidationError, _("Specify an export chunk size less than 1_000_000 GB")
          end
        end

        def validate_export_types!
          repos = repositories(fetch_all: true).where.not(id: ::Katello::Repository.exportable(format: format))
          if repos.any?
            fail ExportValidationError,
                 _("NOTE: Unable to fully export Content View Version '%{content_view} %{current}'"\
                   " it contains repositories with un-exportable content types. \n %{repos}" %
                   { content_view: content_view_version.content_view.name,
                     current: content_view_version.version,
                     repos: Export.generate_product_repo_strings(repositories: repos)})

          end
        end

        def validate_repositories_immediate!
          non_immediate_repos = repositories(fetch_all: true).yum_type.non_immediate
          if non_immediate_repos.any?
            fail ExportValidationError,
                 _("NOTE: Unable to fully export Content View Version '%{content_view} %{current}'"\
                   " it contains repositories without the 'immediate' download policy."\
                   " Update the download policy and sync affected repositories. Once synced republish the content view"\
                   " and export the generated version. \n %{repos}" %
                   { content_view: content_view_version.content_view.name,
                     current: content_view_version.version,
                     repos: Export.generate_product_repo_strings(repositories: non_immediate_repos)})
          end
        end

        def validate_incremental_export_point_release!
          # You are trying to export between an incrementally updated content view version and regular version
          if from_content_view_version.incrementally_updated? != content_view_version.incrementally_updated?
            fail ExportValidationError,
                 _("Cannot incrementally export from a incrementally exported version and a regular version or vice-versa. "\
                   " The exported Content View Version '%{content_view} %{current}' "\
                   "cannot be incrementally exported from version '%{from}.'"\
                               " Please do a full export." % { content_view: content_view_version.content_view.name,
                                                               current: content_view_version.version,
                                                               from: from_content_view_version.version})
          end
        end

        def validate_incremental_export!
          validate_incremental_export_point_release!

          from_exporter = Export.new(smart_proxy: smart_proxy, content_view_version: from_content_view_version)

          from_exporter_repos = generate_repo_mapping(from_exporter.repositories(fetch_all: true))
          to_exporter_repos = generate_repo_mapping(repositories(fetch_all: true))

          invalid_repos_exist = (from_exporter_repos.keys & to_exporter_repos.keys).any? do |repo_id|
            from_exporter_repos[repo_id] != to_exporter_repos[repo_id]
          end

          if invalid_repos_exist
            fail ExportValidationError,
                _("Cannot incrementally export from a filtered and a non-filtered content view version."\
                   " The exported content view version '%{content_view} %{current}' "\
                   " cannot be incrementally updated from version '%{from}.'. "\
                   " Please do a full export." % { content_view: content_view_version.content_view.name,
                                                   current: content_view_version.version,
                                                   from: from_content_view_version.version})
          end
        end

        def generate_repo_mapping(repositories)
          # return a repo mapping with key being the  library_instance_id and value being the repostiory_href
          # used by validate_incremental_export
          repo_map = {}
          repositories.each do |repo|
            repo_map[repo.library_instance_id] = version_href_to_repository_href(repo.version_href)
          end
          repo_map
        end
      end
    end
  end
end
