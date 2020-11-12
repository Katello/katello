module Katello
  module Pulp3
    module ContentViewVersion
      class Import
        include ImportExportCommon

        def initialize(smart_proxy:, content_view_version: nil, path: nil, metadata: nil)
          @smart_proxy = smart_proxy
          @content_view_version = content_view_version
          @path = path
          @metadata = metadata
        end

        def repository_mapping
          mapping = {}
          @metadata[:repository_mapping].each do |key, value|
            repo = @content_view_version.importable_repositories.joins(:root, :product).
                        where("#{::Katello::Product.table_name}" => {:name => value[:product]},
                                                  "#{::Katello::RootRepository.table_name}" => {:name => value[:repository]}).first
            next unless repo&.version_href
            repo_info = fetch_repository_info(repo.version_href)
            mapping[key] = repo_info.name
          end
          mapping
        end

        def create_importer
          api.importer_api.create(name: generate_id,
                                  repo_mapping: repository_mapping)
        end

        def create_import(importer_href)
          [api.import_api.create(importer_href, toc: "#{@path}/#{@metadata[:toc]}")]
        end

        def fetch_import(importer_href)
          api.import_api.list(importer_href).results.first
        end

        def destroy_importer(importer_href)
          import_data = fetch_import(importer_href)
          api.import_api.delete(import_data.pulp_href) unless import_data.blank?
          api.importer_api.delete(importer_href)
        end

        def self.check!(content_view:, metadata:, path:)
          ImportValidator.new(content_view: content_view, metadata: metadata, path: path).check!
        end
      end
    end
  end
end
