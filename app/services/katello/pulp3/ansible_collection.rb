module Katello
  module Pulp3
    class AnsibleCollection < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpAnsibleClient::ContentCollectionsApi.new(Katello::Pulp3::Repository::AnsibleCollection.api_client(SmartProxy.pulp_master!))
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::AnsibleCollection.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:_href) }
      end

      def self.pulp_data(_href)
        #No content read method
        fail NotImplementedError
      end

      def update_model(model)
        custom_json = {}
        custom_json['checksum'] = backend_data['sha256']
        custom_json['namespace'] = backend_data['namespace']
        custom_json['version'] = backend_data['version']
        custom_json['name'] = backend_data['name']
        model.update_attributes!(custom_json)
      end
    end
  end
end
