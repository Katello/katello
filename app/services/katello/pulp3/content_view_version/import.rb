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
          @metadata[:repositories].each do |key, value|
            repo = @content_view_version.importable_repositories.joins(:root, :product).
                        where("#{::Katello::Product.table_name}" => {:label => value[:product][:label]},
                                                  "#{::Katello::RootRepository.table_name}" => {:label => value[:label]}).first
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

        def self.check!(content_view:, metadata:, path:, smart_proxy:)
          ImportValidator.new(smart_proxy: smart_proxy,
                               content_view: content_view,
                               metadata: metadata,
                               path: path).check!
        end

        def self.create_or_update_gpg!(organization:, params:)
          return if params.blank?
          gpg = organization.gpg_keys.find_by(:name => params[:name])
          if gpg
            gpg.update!(params.except(:name))
          else
            gpg = organization.gpg_keys.create!(params)
          end
          gpg
        end

        def self.metadata_map(metadata, product_only: false, custom_only: false, redhat_only: false)
          # Create a map that looks like -> {[product, repo]: {name: 'Foo Repo', label:.....}}
          # these values should be curated from the metadata.
          metadata_map = {}
          metadata[:repositories].values.each do |repo|
            next if (custom_only && repo[:redhat]) || (redhat_only && !repo[:redhat])
            if product_only
              metadata_map[repo[:product][:label]] = repo[:product]
            else
              metadata_map[[repo[:product][:label], repo[:label]]] = repo
            end
          end
          metadata_map
        end

        def self.intersecting_repos_library_and_metadata(organization:, metadata:)
          # Returns repositories in library that are part of the metadata
          # In other words if metadata had repos {label:foo, product: bar}
          # this would match it to the repo with the label foo and product bar
          # in the library.
          queries = metadata_map(metadata).keys.map do |product_label, repo_label|
            repositories_in_library(organization).
                        where("#{Katello::Product.table_name}.label": product_label,
                              "#{Katello::RootRepository.table_name}.label": repo_label)
          end
          queries.inject(&:or)
        end

        def self.repositories_in_library(organization)
          Katello::Repository.
                    in_default_view.
                    exportable.
                    joins(:product => :provider, :content_view_version => :content_view).
                    joins(:root).
                    where("#{::Katello::ContentView.table_name}.organization_id": organization)
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
          repo_ids = intersecting_repos_library_and_metadata(organization: content_view.organization,
                                                             metadata: metadata).
                                                             pluck("#{Katello::Repository.table_name}.id")
          content_view.update!(repository_ids: repo_ids)
        end

        def self.import_cv_name_from_export(name:)
          name.gsub(/^#{::Katello::ContentView::EXPORT_LIBRARY}.*/, ::Katello::ContentView::IMPORT_LIBRARY)
              .gsub(/^Export/, 'Import')
        end

        def self.process_metadata(metadata:)
          fail _("Content View label not provided.") if metadata[:label].blank?
          if metadata[:generated_for].blank?
            metadata[:generated_for] = if metadata[:label].start_with? ::Katello::ContentView::EXPORT_LIBRARY
                                         "library_export"
                                       else
                                         "none"
                                       end
          end
          generated_for = metadata[:generated_for].to_sym

          return metadata if metadata[:generated_for] == :none

          if generated_for == :library_export
            generated_for = :library_import
          elsif generated_for == :repository_export
            generated_for = :repository_import
          end

          { name: import_cv_name_from_export(name: metadata[:name]),
            label: import_cv_name_from_export(name: metadata[:label]),
            description: "Content View used for importing into library",
            generated_for: generated_for
          }
        end

        def self.find_or_create_import_view(organization:, metadata:)
          metadata = process_metadata(metadata: metadata)
          cv = ::Katello::ContentView.find_by(label: metadata[:label],
                                              organization: organization)
          if cv.blank?
            ::Katello::ContentView.create!(metadata.merge(organization: organization, import_only: true))
          elsif !cv.import_only?
            msg = _("Unable to import in to Content View specified in the metadata - '%{name}'. "\
                     "The 'import_only' attribute for the content view is set to false. "\
                     "To mark this Content View as importable, have your system administrator"\
                     " run the following command on the server. "\
                        % { name: cv.name })
            command = "foreman-rake katello:set_content_view_import_only ID=#{cv.id}"
            fail msg + "\n" + command
          else
            cv.update!(description: metadata[:description]) if cv.description != metadata[:description]
            cv
          end
        end
      end
    end
  end
end
