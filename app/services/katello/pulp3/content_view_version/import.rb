module Katello
  module Pulp3
    module ContentViewVersion
      class Import
        include ImportExportCommon

        attr_reader :content_view, :path, :metadata_map, :smart_proxy, :organization

        def initialize(organization:, smart_proxy:, path:, metadata_map:)
          @organization = organization
          @smart_proxy = smart_proxy
          @path = path
          @metadata_map = metadata_map
          @content_view = find_or_create_import_view
        end

        def create_importer(content_view_version)
          api.importer_api.create(name: generate_id(content_view_version),
                                  repo_mapping: repository_mapping(content_view_version))
        end

        def create_import(importer_href)
          [api.import_api.create(importer_href, toc: "#{@path}/#{@metadata_map.toc}")]
        end

        def fetch_import(importer_href)
          api.import_api.list(importer_href).results.first
        end

        def destroy_importer(importer_href)
          import_data = fetch_import(importer_href)
          api.import_api.delete(import_data.pulp_href) unless import_data.blank?
          api.importer_api.delete(importer_href)
        end

        def check!
          ImportValidator.new(import: self).check!
        end

        def intersecting_repos_library_and_metadata
          # Returns repositories in library that are part of the metadata
          # In other words if metadata had repos {label:foo, product: bar}
          # this would match it to the repo with the label foo and product bar
          # in the library.

          queries = metadata_map.repositories.map do |repo|
            if repo.redhat && repo.product.cp_id
              library_repositories.where("#{Katello::Product.table_name}.cp_id": repo.product.cp_id,
                                         "#{Katello::RootRepository.table_name}.label": repo.label)
            else
              library_repositories.where("#{Katello::Product.table_name}.label": repo.product.label,
                                         "#{Katello::RootRepository.table_name}.label": repo.label)
            end
          end
          queries.inject(&:or)
        end

        def library_repositories
          Katello::Repository.
                    in_default_view.
                    exportable.
                    joins(:product => :provider, :content_view_version => :content_view).
                    joins(:root).
                    where("#{::Katello::ContentView.table_name}.organization_id": organization)
        end

        def reset_content_view_repositories!
          # Given metadata from the dump and a content view
          # this method
          # 1) Fetches ids of the library repos whose product name, repo name amd redhat?
          # =>  match values provided in the metadata's repository mapping
          # 2) Removes all the repositories associated to this content view
          # 3) Adds the repositories matched from the dump
          # The main intent of this method is to assume that the user intends for the
          # content view to exaclty look like what is specified in metadata
          repo_ids = intersecting_repos_library_and_metadata.pluck("#{Katello::Repository.table_name}.id")
          content_view.update!(repository_ids: repo_ids)
        end

        private

        def repository_mapping(content_view_version)
          mapping = {}
          relation = content_view_version.importable_repositories.joins(:root, :product)

          metadata_map.repositories.each do |metadata_repo|
            if metadata_repo.redhat && metadata_repo.product.cp_id
              repo = relation.where("#{::Katello::Product.table_name}" => {cp_id: metadata_repo.product.cp_id},
                                        "#{::Katello::RootRepository.table_name}" => {label: metadata_repo.label}).first
            else
              repo = relation.where("#{::Katello::Product.table_name}" => {label: metadata_repo.product.label},
                                        "#{::Katello::RootRepository.table_name}" => {label: metadata_repo.label}).first
            end

            next unless repo&.version_href
            repo_info = fetch_repository_info(repo.version_href)
            mapping[metadata_repo.pulp_name] = repo_info.name
          end
          mapping
        end

        def import_cv_name_from_export(name:, generated_for:)
          if generated_for == :library_import
            ::Katello::ContentView::IMPORT_LIBRARY
          elsif generated_for == :repository_import
            name.gsub(/^Export/, 'Import')
          else
            name
          end
        end

        def import_content_view_params
          generated_for = metadata_map.content_view.generated_for

          if generated_for.blank?
            generated_for = if metadata_map.content_view.label.start_with?(::Katello::ContentView::EXPORT_LIBRARY)
                              "library_export"
                            else
                              "none"
                            end
          end

          generated_for = generated_for.to_sym

          if generated_for == :none
            return {
              name: metadata_map.content_view.name,
              label: metadata_map.content_view.label,
              description: metadata_map.content_view.description,
              generated_for: generated_for
            }
          end

          if generated_for == :library_export
            generated_for = :library_import
          elsif generated_for == :repository_export
            generated_for = :repository_import
          end

          {
            name: import_cv_name_from_export(name: metadata_map.content_view.name, generated_for: generated_for),
            label: import_cv_name_from_export(name: metadata_map.content_view.label, generated_for: generated_for),
            description: "Content View used for importing into library",
            generated_for: generated_for
          }
        end

        def find_or_create_import_view
          fail _("Content View label not provided.") if metadata_map.content_view.label.blank?

          params = import_content_view_params
          cv = ::Katello::ContentView.find_by(label: params[:label],
                                              organization: organization)
          if cv.blank?
            ::Katello::ContentView.create!(params.merge(organization: organization, import_only: true))
          elsif !cv.import_only?
            msg = _("Unable to import in to Content View specified in the metadata - '%{name}'. "\
                     "The 'import_only' attribute for the content view is set to false. "\
                     "To mark this Content View as importable, have your system administrator"\
                     " run the following command on the server. "\
                        % { name: cv.name })
            command = "foreman-rake katello:set_content_view_import_only ID=#{cv.id}"
            fail msg + "\n" + command
          else
            cv.update!(description: params[:description]) if cv.description != params[:description]
            cv
          end
        end
      end
    end
  end
end
