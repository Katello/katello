module Katello
  module Pulp3
    class FileUnit < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "file".freeze
      PULPCORE_CONTENT_TYPE = "file.file".freeze

      def self.content_api
        PulpFileClient::ContentFilesApi.new(Katello::Pulp3::Api::File.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.create_content(options)
        fail _("Artifact Id and relative path are needed to create content") unless options.dig(:file_name) && options.dig(:artifact)
        PulpFileClient::FileContent.new(relative_path: options[:file_name], artifact: options[:artifact])
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::File.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.generate_model_row(unit)
        filename = File.basename(unit['relative_path'].try(:split, '/').try(:[], -1))

        {
          pulp_id: unit[unit_identifier],
          name: filename,
          path: unit['relative_path'],
          checksum: unit['sha256']
        }
      end
    end
  end
end
