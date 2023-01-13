module Katello
  module Pulp3
    module ContentViewVersion
      class Export
        include ImportExportCommon
        SYNCABLE = "syncable".freeze
        IMPORTABLE = "importable".freeze
        FORMATS = [SYNCABLE, IMPORTABLE].freeze

        attr_reader :smart_proxy, :content_view_version, :destination_server, :from_content_view_version, :repository, :base_path
        def self.create(options)
          if options.delete(:format) == SYNCABLE
            SyncableFormatExport.new(options)
          else
            self.new(options)
          end
        end

        def initialize(smart_proxy:,
                        content_view_version: nil,
                        destination_server: nil,
                        from_content_view_version: nil,
                        repository: nil,
                        base_path: nil)
          @smart_proxy = smart_proxy
          @content_view_version = content_view_version
          @destination_server = destination_server
          @from_content_view_version = from_content_view_version
          @repository = repository
          @base_path = base_path
        end

        def repository_hrefs
          version_hrefs.map { |href| version_href_to_repository_href(href) }.uniq
        end

        def version_hrefs
          repositories.pluck(:version_href).compact
        end

        def repositories(fetch_all: false)
          repos = if content_view_version.default?
                    content_view_version.repositories.exportable(format: format)
                  else
                    content_view_version.archived_repos.exportable(format: format)
                  end
          if fetch_all
            repos
          else
            repos.immediate_or_none
          end
        end

        def incremental?
          from_content_view_version.present?
        end

        def generate_exporter_path
          return base_path if base_path
          export_path = "#{content_view_version.content_view.label}/#{content_view_version.version}/"
          export_path += "#{destination_server}/".gsub(/\s/, '_') unless destination_server.blank?
          export_path += "#{date_dir}"
          @base_path = "#{Setting['pulpcore_export_destination']}/#{content_view_version.organization.label}/#{export_path}"
        end

        def date_dir
          DateTime.now.to_s.gsub(/\W/, '-')
        end

        def create_exporter
          exporter_api = api.exporter_api
          options = { name: generate_id(content_view_version), path: generate_exporter_path }
          options[:repositories] = repository_hrefs

          exporter_api.create(options)
        end

        def create_export(exporter_data, chunk_size: nil)
          exporter_href = exporter_data[:pulp_href]
          options = { versions: version_hrefs }
          options[:chunk_size] = "#{chunk_size}GB" if chunk_size
          if from_content_view_version
            from_exporter = Export.new(smart_proxy: smart_proxy, content_view_version: from_content_view_version)
            start_versions = from_exporter.version_hrefs

            # current_cvv - cvv_from , i.e. repos in current cvv that are not in from
            # implying something got added to the current cvv
            # make sure you set the start_versions as 0
            added_repo_hrefs = repository_hrefs - from_exporter.repository_hrefs
            added_repo_hrefs.each do |added_repo_href|
              start_versions << zero_version_href(added_repo_href)
            end

            # cvv_from - current_cvv , i.e. repos in from cvv that are not in current
            # implying something got removed the current cvv
            # make sure the start_versions doesn't contain those
            deleted_repo_hrefs = from_exporter.repository_hrefs - repository_hrefs
            start_versions.select! do |href|
              !deleted_repo_hrefs.include?(version_href_to_repository_href(href))
            end

            options[:start_versions] = start_versions
            options[:full] = 'false'
          end
          export_api = api.export_api
          [export_api.create(exporter_href, options)]
        end

        def fetch_export(exporter_href)
          api.export_api.list(exporter_href).results.first
        end

        def destroy_exporter(exporter_data)
          exporter_href = exporter_data[:pulp_href]
          export_data = fetch_export(exporter_href)
          api.exporter_api.partial_update(exporter_href, :last_export => nil)
          api.export_api.delete(export_data.pulp_href) unless export_data.blank?
          api.exporter_api.delete(exporter_href)
        end

        def validate_chunk_size(size)
          return if size.blank?

          unless size.is_a?(Numeric) && size > 0 && size < 1e6
            fail _("Specify an export chunk size less than 1_000_000 GB")
          end
        end

        def validate!(fail_on_missing_content: true, validate_incremental: true, chunk_size: nil)
          validate_repositories_immediate! if fail_on_missing_content
          validate_incremental_export! if validate_incremental && !from_content_view_version.blank?
          validate_chunk_size(chunk_size)
          validate_export_types! if fail_on_missing_content
        end

        def validate_export_types!
          repos = repositories(fetch_all: true).where.not(id: ::Katello::Repository.exportable(format: format))
          if repos.any?
            fail _("NOTE: Unable to fully export Content View Version '%{content_view} %{current}'"\
                   " it contains repositories with un-exportable content types. \n %{repos}" %
                   { content_view: content_view_version.content_view.name,
                     current: content_view_version.version,
                     repos: self.class.generate_product_repo_strings(repositories: repos)})

          end
        end

        def validate_repositories_immediate!
          non_immediate_repos = repositories(fetch_all: true).yum_type.non_immediate
          if non_immediate_repos.any?
            fail _("NOTE: Unable to fully export Content View Version '%{content_view} %{current}'"\
                   " it contains repositories without the 'immediate' download policy."\
                   " Update the download policy and sync affected repositories. Once synced republish the content view"\
                   " and export the generated version. \n %{repos}" %
                   { content_view: content_view_version.content_view.name,
                     current: content_view_version.version,
                     repos: self.class.generate_product_repo_strings(repositories: non_immediate_repos)})
          end
        end

        def validate_incremental_export!
          from_exporter = Export.new(smart_proxy: smart_proxy, content_view_version: from_content_view_version)

          from_exporter_repos = generate_repo_mapping(from_exporter.repositories(fetch_all: true))
          to_exporter_repos = generate_repo_mapping(repositories(fetch_all: true))

          invalid_repos_exist = (from_exporter_repos.keys & to_exporter_repos.keys).any? do |repo_id|
            from_exporter_repos[repo_id] != to_exporter_repos[repo_id]
          end

          if invalid_repos_exist
            fail _("The exported Content View Version '%{content_view} %{current}' cannot be incrementally updated from version '%{from}'."\
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

        def generate_metadata
          MetadataGenerator.new(export_service: self).generate!
        end

        def self.find_generated_export_view(create_by_default: false,
                                            destination_server:,
                                            organization:,
                                            name:,
                                            generated_for:)
          name += "-#{destination_server}" unless destination_server.blank?
          select_method = create_by_default ? :first_or_create : :first
          ::Katello::ContentView.where(name: name,
                                       organization: organization,
                                       generated_for: generated_for).send(select_method)
        end

        def format
          is_a?(SyncableFormatExport) ? SYNCABLE : IMPORTABLE
        end

        def self.find_library_export_view(create_by_default: false,
                                          destination_server:,
                                          organization:,
                                          format: IMPORTABLE)
          if format == IMPORTABLE
            generated_for = :library_export
            name = ::Katello::ContentView::EXPORT_LIBRARY
          else
            generated_for = :library_export_syncable
            name = "#{::Katello::ContentView::EXPORT_LIBRARY}-SYNCABLE"
          end

          find_generated_export_view(create_by_default: create_by_default,
                                     destination_server: destination_server,
                                     organization: organization,
                                     name: name,
                                     generated_for: generated_for)
        end

        def self.find_repository_export_view(create_by_default: false,
                                              repository:,
                                              format: IMPORTABLE)
          if format == IMPORTABLE
            generated_for = :repository_export
            name = "Export-#{repository.label}-#{repository.library_instance_or_self.id}"
          else
            generated_for = :repository_export_syncable
            name = "Export-SYNCABLE-#{repository.label}-#{repository.library_instance_or_self.id}"
          end
          find_generated_export_view(create_by_default: create_by_default,
                                     destination_server: nil,
                                     organization: repository.organization,
                                     name: name,
                                     generated_for: generated_for)
        end

        def self.generate_product_repo_strings(repositories:)
          repositories.map do |repo|
            _("Product: '%{product}', Repository: '%{repository}'" % { product: repo.product.name,
                                                                       repository: repo.name})
          end
        end
      end
    end
  end
end
