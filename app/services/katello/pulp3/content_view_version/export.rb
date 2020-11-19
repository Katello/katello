module Katello
  module Pulp3
    module ContentViewVersion
      class Export
        include ImportExportCommon

        def initialize(smart_proxy:, content_view_version: nil, destination_server: nil, from_content_view_version: nil)
          @smart_proxy = smart_proxy
          @content_view_version = content_view_version
          @destination_server = destination_server
          @from_content_view_version = from_content_view_version
        end

        def generate_exporter_path
          export_path = "#{@content_view_version.content_view}/#{@content_view_version.version}/#{@destination_server}/#{date_dir}".gsub(/\s/, '_')
          "#{@content_view_version.organization.label}/#{export_path}"
        end

        def date_dir
          DateTime.now.to_s.gsub(/\W/, '-')
        end

        def create_exporter(export_base_dir: Setting['pulpcore_export_destination'])
          api.exporter_api.create(name: generate_id,
                                  path: "#{export_base_dir}/#{generate_exporter_path}",
                                  repositories: repository_hrefs)
        end

        def create_export(exporter_href, chunk_size: nil)
          options = { versions: version_hrefs }
          options[:chunk_size] = "#{chunk_size}MB" if chunk_size
          if @from_content_view_version
            from_exporter = Export.new(smart_proxy: @smart_proxy, content_view_version: @from_content_view_version)
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
          [api.export_api.create(exporter_href, options)]
        end

        def fetch_export(exporter_href)
          api.export_api.list(exporter_href).results.first
        end

        def destroy_exporter(exporter_href)
          export_data = fetch_export(exporter_href)
          api.exporter_api.partial_update(exporter_href, :last_export => nil)
          api.export_api.delete(export_data.pulp_href) unless export_data.blank?
          api.exporter_api.delete(exporter_href)
        end

        def validate_incremental_export!
          return if @from_content_view_version.blank?
          from_exporter = Export.new(smart_proxy: @smart_proxy, content_view_version: @from_content_view_version)

          from_exporter_repos = generate_repo_mapping(from_exporter.repositories)
          to_exporter_repos = generate_repo_mapping(repositories)

          invalid_repos_exist = (from_exporter_repos.keys & to_exporter_repos.keys).any? do |repo_id|
            from_exporter_repos[repo_id] != to_exporter_repos[repo_id]
          end

          if invalid_repos_exist
            fail _("The exported Content View Version '%{content_view} %{current}' cannot be incrementally updated from version '%{from}'."\
                   " Please do a full export." % { content_view: @content_view_version.content_view.name,
                                                   current: @content_view_version.version,
                                                   from: @from_content_view_version.version})
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
          ret = { organization: @content_view_version.organization.name,
                  repository_mapping: {},
                  content_view: @content_view_version.content_view.name,
                  content_view_version: @content_view_version.slice(:major, :minor),
                  incremental: @from_content_view_version.present?
          }

          unless @from_content_view_version.blank?
            ret[:from_content_view_version] = {
              major: @from_content_view_version.major,
              minor: @from_content_view_version.minor
            }
          end

          repositories.each do |repo|
            next if repo.version_href.blank?
            pulp3_repo = fetch_repository_info(repo.version_href).name
            ret[:repository_mapping][pulp3_repo] = {
              repository: repo.root.name,
              product: repo.root.product.name,
              redhat: repo.redhat?
            }
          end
          ret
        end
      end
    end
  end
end
