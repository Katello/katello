module Katello
  module Pulp3
    module ContentViewVersion
      class Export
        include ImportExportCommon
        METADATA_FILE = "metadata.json".freeze

        def initialize(smart_proxy:, content_view_version: nil, destination_server: nil)
          @smart_proxy = smart_proxy
          @content_view_version = content_view_version
          @destination_server = destination_server
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

        def create_export(exporter_href, chunk_size = nil)
          options = { versions: version_hrefs }
          options[:chunk_size] = "#{chunk_size}MB" if chunk_size
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

        def generate_metadata
          ret = { organization: @content_view_version.organization.name,
                  repository_mapping: {},
                  content_view: @content_view_version.content_view.name,
                  content_view_version: {
                    major: @content_view_version.major,
                    minor: @content_view_version.minor
                  }
          }
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
