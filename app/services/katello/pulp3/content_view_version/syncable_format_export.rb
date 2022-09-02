module Katello
  module Pulp3
    module ContentViewVersion
      class SyncableFormatExport < Export
        def create_exporter
          api.yum_exporter_api.create(name: "#{generate_id(content_view_version)}-#{repository.id}",
                                      path: generate_repository_exporter_path,
                                      method: :hardlink)
        end

        def create_export(exporter_data, _options = {})
          [api.yum_export_api.create(exporter_data[:pulp_href], publication: repository.publication_href)]
        end

        def fetch_export(exporter_href)
          api.yum_export_api.list(exporter_href).results.first
        end

        def destroy_exporter(exporter_data)
          exporter_href = exporter_data[:pulp_href]
          export_data = fetch_export(exporter_href)
          api.yum_export_api.delete(export_data.pulp_href)
          api.yum_exporter_api.delete(exporter_href)
        end

        def generate_repository_exporter_path
          if repository.docker?
            content_path = repository.library_instance_or_self.relative_path
          else
            _org, _content, content_path = repository.library_instance_or_self.relative_path.split("/", 3)
          end
          content_path = content_path.sub(%r|^/|, '')
          "#{generate_exporter_path}/#{content_path}".gsub(/\s/, '_')
        end
      end
    end
  end
end
