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

        def self.reset_content_view_repositories_from_metadata!(content_view:, metadata:)
          # Given metadata from the dump and a content view
          # this method
          # 1) Fetches ids of the library repos whose product name, repo name amd redhat?
          # =>  match values provided in the metadata's repository mapping
          # 2) Removes all the repositories associated to this content view
          # 3) Adds the repositories matched from the dump
          # The main intent of this method is to assume that the user intends for the
          # content view to exaclty look like what is specified in metadata

          repos_in_library = Katello::Repository.
                    in_default_view.
                    exportable.
                    joins(:product => :provider, :content_view_version => :content_view).
                    joins(:root).
                    where("#{::Katello::ContentView.table_name}.organization_id" => content_view.organization_id).
                    pluck("#{::Katello::Repository.table_name}.id",
                          "#{::Katello::RootRepository.table_name}.name",
                          "#{::Katello::Product.table_name}.name",
                          "#{::Katello::Provider.table_name}.provider_type"
                          )
          repos_in_library_map = {}
          # repos_in_library_map is going to look like {['repo1', 'product1', false] => 100, ['repo1', 'product1', true] => 200 }
          repos_in_library.each do |id, repo, product, provider_type|
            repos_in_library_map[[repo, product, provider_type == Katello::Provider::REDHAT]] = id
          end

          repo_ids = metadata[:repository_mapping].values.map do |repo|
            repos_in_library_map[[repo[:repository], repo[:product], repo[:redhat]]]
          end
          content_view.update!(repository_ids: repo_ids)
        end

        def self.find_or_create_library_import_view(organization)
          find_or_create_import_view(organization: organization, name: ::Katello::ContentView::IMPORT_LIBRARY)
        end

        def self.find_or_create_import_view(organization:, name:)
          ::Katello::ContentView.where(name: name,
                                       organization: organization,
                                       import_only: true).first_or_create
        end
      end
    end
  end
end
