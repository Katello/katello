module Katello
  module Pulp3
    module ContentViewVersion
      class Import
        include ImportExportCommon
        BASEDIR = '/var/lib/pulp'.freeze

        def initialize(smart_proxy:, content_view_version: nil, path: nil)
          @smart_proxy = smart_proxy
          @content_view_version = content_view_version
          @path = path
        end

        def repository_mapping
          mapping = {}
          metadata[:repository_mapping].each do |key, value|
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
          [api.import_api.create(importer_href, toc: "#{@path}/#{metadata[:toc]}")]
        end

        def fetch_import(importer_href)
          api.import_api.list(importer_href).results.first
        end

        def destroy_importer(importer_href)
          import_data = fetch_import(importer_href)
          api.import_api.delete(import_data.pulp_href) unless import_data.blank?
          api.importer_api.delete(importer_href)
        end

        def metadata
          @metadata ||= self.class.metadata(@path)
        end

        class << self
          def metadata(path)
            JSON.parse(File.read("#{path}/#{Export::METADATA_FILE}")).with_indifferent_access
          end

          def check_permissions!(path, assert_metadata: true)
            fail _("Invalid path specified.") if path.blank? || !File.directory?(path)
            fail _("The import path must be in a subdirectory under '%s'." % BASEDIR) unless path.starts_with?(BASEDIR)

            metadata_file = "#{path}/#{::Katello::Pulp3::ContentViewVersion::Export::METADATA_FILE}"
            if assert_metadata
              fail _("Could not find metadata.json at '%s'." % metadata_file) unless File.exist?(metadata_file)
              fail _("Unable to read the metadata.json at '%s'." % metadata_file) unless File.readable?(metadata_file)
            end

            fail _("Pulp user or group unable to read content in '%s'." % path) unless pulp_user_accessible?(path)
            Dir.glob("#{path}/*").each do |file|
              next if file == metadata_file
              fail _("Pulp user or group unable to read '%s'." % file) unless pulp_user_accessible?(file)
            end
          end

          def pulp_user_accessible?(path)
            pulp_info = fetch_pulp_user_info
            return false if pulp_info.blank?

            stat = File.stat(path)
            stat.gid.to_s == pulp_info.gid ||
              stat.uid.to_s == pulp_info.uid ||
              stat.mode.to_s(8)[-1].to_i >= 4
          end

          def fetch_pulp_user_info
            pulp_user = nil
            Etc.passwd { |u| pulp_user = u if u.name == 'pulp' }
            pulp_user
          end
        end
      end
    end
  end
end
