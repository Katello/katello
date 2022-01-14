module Katello
  module Pulp3
    class Deb < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "deb".freeze

      def self.content_api
        PulpDebClient::ContentPackagesApi.new(Katello::Pulp3::Api::Apt.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.content_api_create(opts = {})
        self.content_api.create(opts)
      end

      def self.create_content(options)
        fail _("Artifact Id and relative path are needed to create content") unless options.dig(:file_name) && options.dig(:artifact)
        PulpDebClient::DebContent.new(relative_path: options[:file_name], artifact: options[:artifact])
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Apt.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def update_model(model)
        custom_json = {}
        custom_json['checksum'] = backend_data['sha256']
        custom_json['filename'] = backend_data['relative_path']
        custom_json['name'] = backend_data['package']
        custom_json['version'] = backend_data['version']
        custom_json['description'] = backend_data['description']
        custom_json['architecture'] = backend_data['architecture']
        custom_json['nva'] = "#{backend_data['package']}_#{backend_data['version']}_#{backend_data['architecture']}"
        model.update!(custom_json)
      end
    end
  end
end
