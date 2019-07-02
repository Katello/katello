module Katello
  module Pulp3
    class FileUnit < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpFileClient::ContentFilesApi.new(Katello::Pulp3::Repository::File.api_client(SmartProxy.pulp_master!))
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::File.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:_href) }
      end

      def update_model(model)
        custom_json = {}
        custom_json['checksum'] = backend_data['sha256']
        custom_json['path'] = backend_data['relative_path']
        custom_json['name'] = File.basename(backend_data['relative_path'].try(:split, '/').try(:[], -1))
        model.update_attributes!(custom_json)
      end
    end
  end
end
